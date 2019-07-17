var sourceAccord = $("#accordeon-template").html();
var templateAccord = Handlebars.compile(sourceAccord);


var modal = {
    window: $(".modal-decline"),
    acceptButton: $(".accept-button"),
    cancelButton: $(".cancel-button")
}

function activateAllContainers() {
    var headers = $(".accordeon-header");
    headers.each(function () {
        var id = $(this).attr("data-id");
        initTinyMce('#container' + id);
    });
    $(".upload").each(function () {
        initUploader(this);
    });
    //$('body').bind("DOMNodeInserted", function () {
    //    clearTimeout(timeout);
    //    timeout = setTimeout(activateClicksOnImages, 500);
    //});
    //(".clickable").addClass("not-initilized");
    //activateClicksOnImages();
}

//function activateClicksOnImages() {
//    $(".clickable.not-initilized").each(function () {
//        var self = this;
//        $(self).on("click", function () {
//            window.open(self.src);
//        });
//        $(self).removeClass("not-initilized");
//    });
//}


function initTinyMce(container) {
    tinymce.init({
        selector: container,
        language: 'ru',
        theme: 'modern',
        menubar: 'format table tools',
        relative_urls: false,
        height: 200,
        autoresize_min_height: 300,
        plugins: [
            'advlist autolink lists link image charmap print preview hr anchor pagebreak',
            'searchreplace wordcount visualblocks visualchars code fullscreen',
            'insertdatetime media nonbreaking save table contextmenu directionality',
            'template paste textcolor colorpicker textpattern imageupload poll audio fileupload gallery videoupload autoresize noneditable'
        ],
        toolbar1: 'undo redo | styleselect fontselect fontsizeselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
        toolbar2: 'forecolor backcolor | filebtn imgupld gallerybtn audiobtn vidupl pollbtn',
        content_css: [
            '/_layouts/15/1049/styles/Themable/corev15.css',
            '/_layouts/15/WSSC.PRT.PNT6.Design/Css/GLB_Global.css',
            '/_layouts/15/WSSC.PRT.PNT6.Highlights/css/tinymce.css'
        ],
        table_class_list: [{ title: 'Стандартный', value: 'standart' }],
        noneditable_editable_class: 'js-editable',
        noneditable_noneditable_class: 'js-noneditable'
    });
}

function initUploader(container) {
    var id = $(container).attr("data-id");
    var type = $(container).attr("data-type");
    var guid = $(".global-wrap").attr("data-guid");

    $(container).fileupload({
        dataType: "json",
        dropZone: null,
        formData: {
            method: 'WSSC.PRT.PNT6.Highlights:Accordeon:AjaxUploadFile',
            id: id,
            type: type,
            guid: guid,
            rand: Math.random()
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert("Не удалось загрузить файл на сервер");
            if (window.console) console.log('textStatus: ' + textStatus);
            if (window.console) console.log('errorThrown: ' + errorThrown);
        },
        done: function (e, data) {
            if (data.result.Error) {
                if (window.console) console.log(data.result.Error);
                alert('Произошла ошибка при загрузке файла на сервер');
            }
            else {
                var header = $(".accordeon-header[data-id='" + id + "']");
                var icon = header.find(".icon");

                if (icon.length === 0) {
                    header.append("<img class='icon' />");
                    header.append("<img class='active-icon' />");
                    header.addClass("with-icon");
                    var icon = header.find(".icon");
                }
                var activeIcon = header.find(".active-icon");

                if (data.result.Type === "off") {
                    $("#image-off-uploader-img" + id).attr("src", data.result.ImageUrl);
                    icon.attr("src", data.result.ImageUrl);
                }
                else {
                    $("#image-on-uploader-img" + id).attr("src", data.result.ImageUrl);
                    activeIcon.attr("src", data.result.ImageUrl);
                }
            }
        }
    });
}

function createNew() {
    var guid = $(".global-wrap").attr("data-guid");
    var idOfPage = $(".global-wrap").attr("data-id");

    $.ajax({
        url: '/_layouts/15/WSSC.PRT.PNT6.Core/Handlers/Ajax.ashx',
        data: ({
            method: 'WSSC.PRT.PNT6.Highlights:Accordeon:AjaxCreateAccordChildInDb',
            rand: Math.random(),
            Id: idOfPage
        }),
        type: 'POST',
        success: function (result) {
            if (result) {

                var id = result;
                var context = {
                    accordId: id,
                };

                var html = templateAccord(context);
                $(".global-wrap").append(html);
                initTinyMce('#container' + id);
                initUploader('#image-off-uploader' + id);
                initUploader('#image-on-uploader' + id);
            }
            else {

                console.log('sending create form failed');
            }
        }
    });

}
////delete
function showDeleteModal(obj) {
    var thisWrap = $(obj).parents(".accordeon-wrap").first();
    var thisId = thisWrap.find(".accordeon-header").attr("data-id");
    modal.acceptButton.attr("data-id", thisId);
    modal.window.show();
}

function closeModal() {
    modal.window.hide();
}

function deleteInfo(obj) {
    var thisId = $(obj).attr("data-id");

    $.ajax({
        url: '/_layouts/15/WSSC.PRT.PNT6.Core/Handlers/Ajax.ashx',
        data: ({
            method: 'WSSC.PRT.PNT6.Highlights:Accordeon:AjaxDeleteAccord',
            rand: Math.random(),
            Id: thisId
        }),
        type: 'POST',
        success: function (result) {
            if (result == 'True') {
                var header = $(".accordeon-header[data-id=" + thisId + "]");
                var wrap = header.parents(".accordeon-wrap").first();
                wrap.remove();
                modal.window.hide();
            }
            else {

                console.log('sending delete form failed');
            }
        }
    });
}

function deleteImage(obj) {
    var thisObj = $(obj);
    var id = thisObj.attr("data-id");
    var type = thisObj.attr("data-type");

    $.ajax({
        url: '/_layouts/15/WSSC.PRT.PNT6.Core/Handlers/Ajax.ashx',
        data: ({
            method: 'WSSC.PRT.PNT6.Highlights:Accordeon:AjaxDeleteImage',
            rand: Math.random(),
            id: id,
            type: type
        }),
        type: 'POST',
        success: function (result) {
            if (result == 'True') {
                if (type === "off") {
                    $("#image-off-uploader-img" + id).attr("src", "");
                } else {
                    $("#image-on-uploader-img" + id).attr("src", "");
                }

                if ($("#image-on-uploader-img" + id).attr("src") === "" && $("#image-off-uploader-img" + id).attr("src") === "") {
                    var header = $(".accordeon-header[data-id='" + id + "']");
                    header.find(".icon").remove();
                    header.find(".active-icon").remove();
                    header.removeClass("with-icon");
                }
            }
            else {

                console.log('sending delete image form failed');
            }
        }
    });
}

function IsNumeric(val) {
    return Number(parseFloat(val)) == val;
}
////////
function sendForm(obj) {
    var thisWrap = $(obj).parents(".accordeon-wrap").first();
    var name = thisWrap.find(".updating-name-input").val();
    var priority = thisWrap.find(".updating-priority-input").val();

    if (!IsNumeric(priority)) {
        alert("Поле приоритет должно быть числом");
        return;
    }

    if (Number(priority) > 10 || Number(priority) < 1) {
        alert("Поле приоритет должно быть от 1 до 10");
        return;
    }

    var thisId = thisWrap.find(".accordeon-header").attr("data-id");
    var html = tinyMCE.get('container' + thisId).getContent();



    $.ajax({
        url: '/_layouts/15/WSSC.PRT.PNT6.Core/Handlers/Ajax.ashx',
        data: ({
            method: 'WSSC.PRT.PNT6.Highlights:Accordeon:AjaxUpdateAccord',
            rand: Math.random(),
            name: name,
            priority: priority,
            html: html,
            Id: thisId,
            iconImage: $("#image-off-uploader-img" + thisId).attr("src"),
            iconImageActive: $("#image-on-uploader-img" + thisId).attr("src")
        }),
        type: 'POST',
        success: function (result) {
            if (result == 'True') {
                var showBlock = thisWrap.find(".show-block");
                var updateBlock = thisWrap.find(".updating-block");
                var showName = thisWrap.find(".show-name-value");
                var showPriority = thisWrap.find(".show-priority-value");
                var showHtml = thisWrap.find(".content");
                var updateButton = thisWrap.find(".update-button");

                showName.html(name);
                showPriority.html(priority);
                showHtml.html(html);
                showBlock.show();
                updateBlock.hide();
                updateButton.show();
                if (imageFullsizeActivator != null) {
                    imageFullsizeActivator.reInitilizeClickableImages();
                }
                //$(".clickable").addClass("not-initilized");

            }
            else {

                console.log('sending update form failed');
            }
        }
    });
}

$(".global-wrap").on("click", ".accordeon-header", function (event) {
    var target = event.target ? $(event.target) : $(event.srcElement);
    if (target.attr('class') !== "update-button" && target.attr('class') !== "delete-button") {
        var thisWrap = $(this).parents(".accordeon-wrap").first();
        var inner = thisWrap.find(".inner");
        var closeIcon = thisWrap.find(".close-icon");
        if (!inner.is(":visible")) {
            inner.show();
            closeIcon.css("background-position", "left");
        }
        else {
            inner.hide();
            closeIcon.css("background-position", "right");
        }
    }
});

function updateInfo(obj) {
    var thisWrap = $(obj).parents(".accordeon-wrap").first();
    var inner = thisWrap.find(".inner");
    var id = thisWrap.find(".accordeon-header").attr("data-id");
    var closeIcon = thisWrap.find(".close-icon");
    var showBlock = thisWrap.find(".show-block");
    var showName = thisWrap.find(".show-name-value");
    var showPriority = thisWrap.find(".show-priority-value");
    var showHtml = thisWrap.find(".content");

    var updateBlock = thisWrap.find(".updating-block");
    var updateName = thisWrap.find(".updating-name-input");
    var updatePriority = thisWrap.find(".updating-priority-input");

    var html = "";
    $.getJSON('/_layouts/15/WSSC.PRT.PNT6.Core/Handlers/Ajax.ashx', {
        method: 'WSSC.PRT.PNT6.Highlights:Accordeon:AjaxGetHtml',
        rand: Math.random(),
        id: id
    }).then(function (response) {
        if (response.Error) {
            console.log(response);
        } else {
            html = response;
            tinyMCE.get('container' + id).setContent(html);
        }
    });

    updateName.val(showName.text());
    updatePriority.val(showPriority.text());
    showBlock.hide();
    updateBlock.show();
    inner.show();
    closeIcon.css("background-position", "left");
    $(obj).hide();
}

function cancel(obj) {
    var thisWrap = $(obj).parents(".accordeon-wrap").first();
    var showBlock = thisWrap.find(".show-block");
    var updateBlock = thisWrap.find(".updating-block");
    var updateButton = thisWrap.find(".update-button");

    updateBlock.hide();
    showBlock.show();
    updateButton.show();
}


activateAllContainers();


$(document).ready(function () {


});