<cfif not variables.permission_type IS "Edit">
	<cfinclude template="unauthorized_page.cfm">
    <cfabort>
</cfif>

<!DOCTYPE html>
<html>
<head>
<title>DD 254 Upload</title>
<cfinclude template="meta.html">
<link rel="stylesheet" type="text/css" href="styles.css">
<link rel="stylesheet" type="text/css" href="js/dndUpload/dndUpload.css">
<style>
	#container{width:650px;}
	#wrapper {
		padding: 15px;
	}
	#seconds {
		margin-left: 20px;
		display: inline-block;
		width: 600px; 
		height: 15px;
		padding: 5px;
	}
	.remove:link {color: #00F; text-decoration:underline;}
	.remove:visited {color: #00F; text-decoration:underline;}
	.remove:hover {color: #00F; text-decoration:none;}
	.remove:active {color: #00F; text-decoration:underline;}

</style>
<script src="/jquery/jquery-1.11.1.min.js"></script>
<script src="js/dndUpload/dndUpload.js"></script>
<script>
	uploadInit(
		{
			'maxFiles':1, 
			'secondsToWait':10, 
			'acceptedExtensions':['pdf'],
			'acceptedTypes':['application/pdf'],
			'containerName':'wrapper',
			'containerBottomMarginNormal':'15px',
			'containerBottomMarginExpanded':'120px',
			'consoleContainerName':'console',
			'fileDataContainerPrefix':'filedata',
			'fileInfoContainerPrefix':'fileinfo',
			'removeLinkClass':'consoleremove remove'
		});
</script>
</head>
<body>
<div id="container">
	<cfinclude template="header.html">
    <div id="wrapper">
        <cfinclude template="menu.html">
		<div align="center"><h2 class=title>DD 254 Upload</h2><hr /></div>
		<p>
		Upload a DD 254 <strong>PDF interactive form only</strong>! Only the PDF document with active form fields can be parsed for information.
		<br><br>
		If you upload a PDF that has been digitally signed it will be flattened and the form fields removed and the fields cannot be recognized or processed.
		</p>
		<!--- 'dropzone' is where files are dropped, and 'console' is for info/error messages --->	
		<div>
			<div id="dropzone" class=dznormal ondrop="drop_handler(event);" ondragover="dragover_handler(event);" 
				ondragenter="dragenter_handler(event);" ondragleave="dragleave_handler(event);"
				onClick="dropzone_click_handler()"><br>Drop file here<br>or<br>click to browse</div>
			<div id=console></div>
		</div>
		<br>
		<form action="dd254_parse.cfm" method=post enctype="multipart/form-data" id=theForm method=post onSubmit="return submit_handler();">
			<input type=hidden name=filedata1 id=filedata1>
			<input type=file name=myfiles id=myfiles multiple accept=".pdf" class="invis" onChange="onchange_handler(event);">
			<input type=submit value="Upload File">
		</form>
		<br>
		<!--- Div for file stats when selected --->
		<div id="fileinfo1" class="invis"></div>
	</div>
</div>
<cfinclude template="footer.html">
</body>
</html>
