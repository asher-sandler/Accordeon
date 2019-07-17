function create-Accordeon-From-Template($oacc)
{
	$crlf = [char][int]13+[char][int]10
		$script +=@'
<div style="background: url(&quot;/publishingimages/ico/req_bg.png&quot;); min-height: 204px;">
'@
		$script +=$crlf;
		$script +=@'
   <h1 style="background: none; color: #ffffff;">Страница</h1>
'@
		$script +=$crlf;
		$script +=@'
</div>	
'@
		$script +=$crlf;
# 17
		$script +=@'
<link rel="stylesheet" href="/_layouts/15/WSSC.PRT.PNT6.Highlights/css/accordeon.css" type="text/css" />
'@
		$script +=$crlf;
# 19
		$script +=@'
<script src='/_layouts/15/WSSC.PRT.PNT6.Core/Js/jquery.ui.widget.js?version=2307180115' type='text/javascript'></script>
'@
		$script +=$crlf;
		$script +=@'
<script src='/_layouts/15/WSSC.PRT.PNT6.Core/Js/jquery.fileupload.js?version=2307180115' type='text/javascript'></script>
'@
		$script +=$crlf;
		$script +=@'
<script src='/_layouts/15/WSSC.PRT.PNT6.Core/Js/jquery.iframe-transport.js?version=2307180115' type='text/javascript'></script>
'@
		$script +=$crlf;
# 23
		$script +=@'
<div class="global-wrap" >
'@
		$script +=$crlf;
# 25
# 26
    foreach($acc in $oacc){
		$script +=@'
    <div class="accordeon-wrap">
'@
		$script +=$crlf;
		$script +=@'
        <div class="accordeon-header with-icon" >
'@
		$script +=$crlf;
# 30
		$script +='            <img class="active-icon" src="/gucfo/Kaluga/icons/w/'+$acc.Image+'.png" />'+$crlf
		$script +='            <img class="icon" src="/gucfo/Kaluga/icons/b/'+$acc.Image+'.png" />'+$crlf
# 33
		$script +='            <div class="show-name-value">'+$acc.Name+'</div>'+$crlf
		$script +=@'
            <div class="close-icon"></div>
'@
		$script +=$crlf;
# 36
		$script +=@'
        </div>
'@
		$script +=$crlf;
		$script +=@'
        <div class="inner">
'@
		$script +=$crlf;
		$script +=@'
            <div class="show-block">
'@
		$script +=$crlf;
		$script +=@'
                <div class="show-priority-value">10</div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="show-field-container clearfix">
'@
		$script +=$crlf;
		$script +=@'
                    <div class="content clearfix">
'@
		$script +=$crlf;
					foreach($cont in $acc.Contents){
		$script +=@'
					<p>
'@
		$script +=$crlf;
		$script +='					<a class="wss-fileeditable" href="'+$cont.URI+'">'+$crlf
		$script +=@'
					<img class="wss-fileeditable__icon" src="/_layouts/15/WSSC.PRT.PNT6.Highlights/img/document-ico.png" />
'@
		$script +=$crlf;
		$script +='					'+$cont.Name+''+$crlf
		$script +=@'
					</a>
'@
		$script +=$crlf;
		$script +=@'
					</p>
'@
		$script +=$crlf;
					}
		$script +=@'
					</div>
'@
		$script +=$crlf;
		$script +=@'
                </div>
'@
		$script +=$crlf;
# 53
		$script +=@'
            </div>
'@
		$script +=$crlf;
# 55
		$script +=@'
        </div>
'@
		$script +=$crlf;
		$script +=@'
    </div>
'@
		$script +=$crlf;
# 58
	}
# 60
# 61
		$script +=@'
</div>
'@
		$script +=$crlf;
# 63
# 64
		$script +=@'
<div id="modal-decline" class="modal-decline">
'@
		$script +=$crlf;
		$script +=@'
    <div class="modal-content">
'@
		$script +=$crlf;
		$script +=@'
        <div class="text">Удалить данный элемент?</div>
'@
		$script +=$crlf;
		$script +=@'
        <div class="accept-button" data-id="" onclick="deleteInfo(this);">Да</div>
'@
		$script +=$crlf;
		$script +=@'
        <div class="cancel-button" onclick="closeModal();">Отмена</div>
'@
		$script +=$crlf;
		$script +=@'
    </div>
'@
		$script +=$crlf;
		$script +=@'
</div>
'@
		$script +=$crlf;
# 72
		$script +=@'
<script id="accordeon-template" type="text/x-handlebars-template">
'@
		$script +=$crlf;
		$script +=@'
    <div class="accordeon-wrap">
'@
		$script +=$crlf;
		$script +=@'
        <div class="accordeon-header" data-id="{{accordId}}">
'@
		$script +=$crlf;
		$script +=@'
            <div class="show-name-value"></div>
'@
		$script +=$crlf;
		$script +=@'
            <div class="close-icon"></div>
'@
		$script +=$crlf;
		$script +=@'
            <div class="delete-button" title="Удалить элемент" onclick="showDeleteModal(this);"></div>
'@
		$script +=$crlf;
		$script +=@'
            <div class="update-button" title="Редактировать элемент" onclick="updateInfo(this);"></div>
'@
		$script +=$crlf;
		$script +=@'
        </div>
'@
		$script +=$crlf;
		$script +=@'
        <div class="inner">
'@
		$script +=$crlf;
		$script +=@'
            <div class="show-block">
'@
		$script +=$crlf;
# 83
		$script +=@'
                <div class="show-priority-value"></div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="show-field-container">
'@
		$script +=$crlf;
		$script +=@'
                    <div class="content clearfix"></div>
'@
		$script +=$crlf;
		$script +=@'
                </div>
'@
		$script +=$crlf;
		$script +=@'
            </div>
'@
		$script +=$crlf;
# 89
		$script +=@'
            <div class="updating-block">
'@
		$script +=$crlf;
		$script +=@'
                <div class="updating-name-block">
'@
		$script +=$crlf;
		$script +=@'
                    <div class="updating-name-title">Название</div>
'@
		$script +=$crlf;
		$script +=@'
                    <input class="updating-name-input" type="text" />
'@
		$script +=$crlf;
		$script +=@'
                </div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="updating-priority-block">
'@
		$script +=$crlf;
		$script +=@'
                    <div class="updating-priority-title">Приоритет</div>
'@
		$script +=$crlf;
		$script +=@'
                    <input class="updating-priority-input" type="text" />
'@
		$script +=$crlf;
		$script +=@'
                </div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="updating-images">
'@
		$script +=$crlf;
		$script +=@'
                    <div class="image-off">
'@
		$script +=$crlf;
		$script +=@'
                        <input class="upload" id="image-off-uploader{{accordId}}" data-id="{{accordId}}" data-type="off" type="file" name="files[]" data-url="/_layouts/15/wssc.prt.pnt6.core/Handlers/ajax.ashx" style="display: none;">
'@
		$script +=$crlf;
		$script +=@'
                        <label for="image-off-uploader{{accordId}}" class="upload-label">Загрузить иконку</label>
'@
		$script +=$crlf;
		$script +=@'
                        <div class="image-with-delete-container">
'@
		$script +=$crlf;
		$script +=@'
                            <img id="image-off-uploader-img{{accordId}}" class="upload-image" src="" />
'@
		$script +=$crlf;
		$script +=@'
                            <span id="image-off-delete{{accordId}}" class="image-delete" data-id="{{accordId}}" data-type="off" title="Удалить" onclick="deleteImage(this);"></span>
'@
		$script +=$crlf;
		$script +=@'
                        </div>
'@
		$script +=$crlf;
		$script +=@'
                    </div>
'@
		$script +=$crlf;
		$script +=@'
                    <div class="image-on">
'@
		$script +=$crlf;
		$script +=@'
                        <input class="upload" id="image-on-uploader{{accordId}}" data-id="{{accordId}}" data-type="on" type="file" name="files[]" data-url="/_layouts/15/wssc.prt.pnt6.core/Handlers/ajax.ashx" style="display: none;">
'@
		$script +=$crlf;
		$script +=@'
                        <label for="image-on-uploader{{accordId}}" class="upload-label">Загрузить активную иконку</label>
'@
		$script +=$crlf;
		$script +=@'
                        <div class="image-with-delete-container">
'@
		$script +=$crlf;
		$script +=@'
                            <img id="image-on-uploader-img{{accordId}}" class="upload-image-on" src="" />
'@
		$script +=$crlf;
		$script +=@'
                            <span id="image-on-delete{{accordId}}" class="image-delete" data-id="{{accordId}}" data-type="on" title="Удалить" onclick="deleteImage(this);"></span>
'@
		$script +=$crlf;
		$script +=@'
                        </div>
'@
		$script +=$crlf;
		$script +=@'
                    </div>
'@
		$script +=$crlf;
		$script +=@'
                </div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="updating-container-title">Контент</div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="updating-field-container">
'@
		$script +=$crlf;
		$script +=@'
                    <textarea class="container-add" id="container{{accordId}}"></textarea>
'@
		$script +=$crlf;
		$script +=@'
                </div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="cancel-button" onclick="cancel(this);">Отменить</div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="send-button" onclick="sendForm(this);">Сохранить</div>
'@
		$script +=$crlf;
		$script +=@'
                <div class="clearfix"></div>
'@
		$script +=$crlf;
		$script +=@'
            </div>
'@
		$script +=$crlf;
		$script +=@'
        </div>
'@
		$script +=$crlf;
		$script +=@'
    </div>
'@
		$script +=$crlf;
		$script +=@'
</script>
'@
		$script +=$crlf;
# 128
		$script +=@'
<script type="text/javascript" src="/_layouts/15/WSSC.PRT.PNT6.Core/Plugins/tinymce/tinymce.min.js"></script>
'@
		$script +=$crlf;
		$script +=@'
<script type="text/javascript" src="/_layouts/15/WSSC.PRT.PNT6.Highlights/js/accordeon.js"></script>
'@
		$script +=$crlf;
# 131
# 132
	return $script
# 134
}

