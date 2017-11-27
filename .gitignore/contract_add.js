/*
	JS code to handle the mammoth contract entry form that can have 8 bazillion possible combinations
*/

$(document).ready(function()
{
	// hide form sections that are optional until a box/button is selected
	$(".dd254_toggle, .onbase_toggle, .cso_toggle_dd254, .cso_toggle_cage_code, .subcontractor_toggle, .company_toggle,\
	   .cage_code_toggle_cage_code, .company_toggle_subcontractor, .company_toggle_cage_code").hide();
	
	// make it possible to unselect a radio button (and close the associated form section). Can't believe this can't be done natively
	$(':radio').mousedown(function(e)
	{
		var $self = $(this);
		if($self.is(':checked'))
		{
			var uncheck = function()
			{
				setTimeout(function() {$self.removeAttr('checked'); $self.trigger('change');}, 0);
			};
			var unbind = function()
			{
				$self.unbind('mouseup', up);
			};
			var up = function()
			{
				uncheck();
				unbind();
			};
			$self.bind('mouseup', up);
			$self.one('mouseout', unbind);
		}
	});
});

// show/hide the DD254 section
function toggle_flags()
{
	if ($('#dd254yes:checked').val() == 'yes')
	{
		$(".dd254_toggle").show();
	}
	else
	{
		$(".dd254_toggle").hide();
	}
}

// show/hide any CSO section in the form
function toggle_cso(index)
{
	if (!index) index='';
	if ($('#cso_new'+index).is(':checked'))
	{
		// clear and disable the associated dropdown list if a new one is being added
		$("#cso_id"+index).val([]);
		$("#cso_id"+index).attr('disabled','disabled');
		if ($("#cso_req"+index)) $("#cso_req"+index).hide();
		$('.cso_toggle'+index).show();
	}
	else
	{	
		$("#cso_id"+index).removeAttr('disabled');
		if ($("#cso_req"+index)) $("#cso_req"+index).show();
		$('.cso_toggle'+index).hide();
	}
}

// show/hide the onbase form section
function toggle_onbase()
{
	if ($('#onbase:checked').val() == 'yes')
	{
		$(".onbase_toggle").show();
	}
	else
	{
		$(".onbase_toggle").hide();
	}
}

// show/hide the subcontractor section
function toggle_subcontractor()
{
	if ($('#subcontractoryes:checked').val() == 'yes')
	{
		$('.subcontractor_toggle').show();
	}
	else
	{
		$('.subcontractor_toggle').hide();
	}
}

// show/hide any company section in the form
function toggle_company(index)
{
	if (!index) index='';
	if ($('#company_new'+index).is(':checked'))
	{
		// clear and disable the associated dropdown list if a new one is being added
		$("#company_id"+index).val([]);
		$("#company_id"+index).attr('disabled','disabled');
		if ($("#company_id_req"+index)) $("#company_id_req"+index).hide();
		$('.company_toggle'+index).show();
	}
	else
	{
		$("#company_id"+index).removeAttr('disabled');
		if ($("#company_id_req"+index)) $("#company_id_req"+index).show();
		$('.company_toggle'+index).hide();
	}
}

// show/hide any cage code section in the form
function toggle_cage_code(index)
{
	if (!index) index='';
	if ($('#cage_code_new'+index).is(':checked'))
	{
		// clear and disable the associated dropdown list if a new one is being added
		$("#cage_code_id"+index).val([]);
		$("#cage_code_id"+index).attr('disabled','disabled');
		if ($("#cage_code_req"+index)) $("#cage_code_req"+index).hide();
		$('.cage_code_toggle'+index).show();
	}
	else
	{
		$("#cage_code_id"+index).removeAttr('disabled');
		if ($("#cage_code_req"+index)) $("#cage_code_req"+index).show();
		$('.cage_code_toggle'+index).hide();
	}
}

// the required form fields associated with each section of the contract
var contract_req = ['contract_number','contract_status','address1','city','state','zip_code'];
var company_req = ['company_name'];
var cage_code_req = ['cage_code', 'company_name', 'address1', 'city', 'state', 'zip_code'];
var cso_req = ['cso_symbol', 'cso_location', 'cso_address1', 'cso_city', 'cso_state', 'cso_zip_code', 'cso_phone'];
var subcontractor_req = ['prime_contract_number','prime_contractor'];
var location_req = ['cage_code','cso'];

function validation()
{
	var message = '';
	
	// check the main contract fields
	message += processMessage(contract_req, '', '', 0);
	
	// if a new company is being added, check those fields
	if ($('#company_new').is(':checked'))
	{
		message += processMessage(company_req, '', '', 0);
	}
	
	// if a new cage code is being added
	if ($('#cage_code_new_cage_code').is(':checked'))
	{
		// make a copy of the generic fields for a cage code
		var cage_code_temp = cage_code_req.slice();
		for (var i = 0; i < cage_code_temp.length; i++) 
		{
			// add the proper suffix for this new set of cage code form fields
			cage_code_temp[i] += "_cage_code";
		}
		// check the fields for values and report back any that need to be filled
		message += processMessage(cage_code_temp, 'New Cage Code:', '_cage_code', 0);

		// if the new cage code needs a new CSO
		if ($('#cso_new_cage_code').is(':checked'))
		{
			// make a copy of the generic fields for a CSO
			var cso_temp = cso_req.slice();
			for (var i = 0; i < cso_temp.length; i++) 
			{
				// add the proper suffix for this new set of cage code CSO form fields
				cso_temp[i] += "_cage_code";
			}
			// check the fields for values and report back any that need to be filled
			message += processMessage(cso_temp, 'New Cage Code CSO:', '_cage_code', 1);
		}
		
		// if the new cage code needs a new company
		if ($('#company_new_cage_code').is(':checked'))
		{
			// make a copy of the generic fields for a company
			var company_temp = company_req.slice();
			for (var i = 0; i < company_temp.length; i++) 
			{
				// add the proper suffix for this new set of cage code company form fields
				company_temp[i] += "_cage_code";
			}
			// check the fields for values and report back any that need to be filled
			message += processMessage(company_temp, 'New Cage Code Company:', '_cage_code', 1);
		}
	}
	
	// if there is DD254 information to add
	if ($('#dd254yes:checked').val() == 'yes')
	{
		// if the DD254 needs a new CSO
		if ($('#cso_new_dd254').is(':checked'))
		{
			// make a copy of the generic fields for a CSO
			var cso_temp = cso_req.slice();
			for (var i = 0; i < cso_temp.length; i++) 
			{
				// add the proper suffix for this new set of dd254 CSO form fields
				cso_temp[i] += "_dd254";
			}
			// check the fields for values and report back any that need to be filled
			message += processMessage(cso_temp, 'New DD254 CSO:', '_dd254', 0);
		}
	}
	
	// if the subcontractor section is checked
	if ($('#subcontractoryes:checked').val() == 'yes')
	{
		message += processMessage(subcontractor_req, 'Subcontractor Information', '_prime', 0);
	
		// if the sub needs a new company as the prime
		if ($('#company_new_subcontractor').is(':checked'))
		{
			// make a copy of the generic fields for a company
			var company_temp = company_req.slice();
			for (var i = 0; i < company_temp.length; i++) 
			{
				// add the proper suffix for this new set of subcontractor company form fields
				company_temp[i] += "_subcontractor";
			}
			// check the fields for values and report back any that need to be filled
			message += processMessage(company_temp, 'New Subcontractor Prime Company:', '_subcontractor', 1);
		}
	}
	
	// for each added location, plow through stuff looking for checkboxes
	for (var j = 1; j <= locations; j++)
	{
		var checkFields = [];
		var ccFields = [];
		var compFields = [];
		var csoFields = [];

		// new cage code for the added location?		
		if ($('#cage_code_new_location_'+j).is(':checked'))
		{
			// make a copy of the generic fields for a cage code
			ccFields = cage_code_req.slice();
			for (var i = 0; i < ccFields.length; i++) 
			{
				// add the proper suffix for this set of new location cage code form fields
				ccFields[i] += "_location_"+j;
			}

			// if the new location needs a new company
			if ($('#company_new_location_'+j).is(':checked'))
			{
				// make a copy of the generic fields for a company
				compFields = company_req.slice();
				for (var i = 0; i < compFields.length; i++) 
				{
					// add the proper suffix for this set of new location cage company fields
					compFields[i] += "_location_"+j;
				}
			}
		}
		// if the new cage code box is NOT checked, need to validate the dropdown list
		else
		{
			checkFields.push('cage_code_id_location_'+j);
		}
		
		// new CSO for the added location?
		if ($('#cso_new_location_'+j).is(':checked'))
		{
			// make a copy of the generic fields for a CSO
			csoFields = cso_req.slice();
			for (var i = 0; i < csoFields.length; i++) 
			{
				// add the proper suffix for this set of new location CSO form fields
				csoFields[i] += "_location_"+j;
			}
		}
		// if the new CSO box is NOT checked, need to validate the dropdown list
		else
		{
			checkFields.push('cso_id_location_'+j);
		}
		
		// for each chunk of fields being checked, do the work and report any empty required fields
		if (checkFields.length > 0) message += processMessage(checkFields, 'Added Location ' + j + ':', "_location_"+j, 0);
		if (ccFields.length > 0) message += processMessage(ccFields, 'Added Location ' + j +' Cage Code:', "_location_"+j, 0);
		if (compFields.length > 0) message += processMessage(compFields, 'Added Location ' + j +' Cage Code Company:', "_location_"+j, 1);
		if (csoFields.length > 0) message += processMessage(csoFields, 'Added Location ' + j +' CSO:', "_location_"+j, 0);
	}

	//console.log(req_fields_temp);
	//return false;
	
	// there are so many fields that can be required the message can be bigger than the alert box. Show 25 lines of the message
	//  with a count of how many more there are.
	var lines = message.split("\n");
	if (lines.length > 25) 
	{
		var remainder = lines.length-25;
		message = lines.slice(0,25).join("\n");
		message += "\n\n... and "+remainder+' more item';
		if (remainder > 1) message += 's';
		message += '.';
	}
	
	alert ("The following fields are required before the form can be submitted:\n\n"+message);
	return false;
}

/* 
	produces a message identifying any of the given fields that are empty
	  fields - an array of form fields to check
	  header - an optional header to prepend above the reported fields
	  ignore - a string to remove from the field names for prettier reporting
	  indent - shoves the message to the right the specified number of indentations (1 = 3 spaces, 2 = 6 spaces, etc)
*/
function processMessage(fields, header, ignore, indent)
{
	var myMessage = '';
	if (indent.length < 1) indent = 0;
	
	var requiredFields = fields.slice();
	for (var i = 0; i < requiredFields.length; i++)
	{
		var s = document.getElementById(requiredFields[i]);
		if (s && s.value.length < 1) 
		{
			if (header && myMessage.length == 0) 
			{
				myMessage += "\n";
				if (indent) myMessage += Array(indent*3+1).join(' ');
				myMessage += header+"\n";
			}
			if (header) myMessage += Array(indent*3+4).join(' ');
			myMessage += polish(s.id, ignore) + "\n";
		}
	}
	
	return myMessage;
}

// the field name is the label reported in the message so pretty it up.
//	 Replace underscores with spaces, capitalize the first letter of each resulting word
//	 if 'ignore' is optionally used, remove the ignore string from the field name before processing
function polish(string, ignore)
{
	if (ignore) string = string.replace(RegExp(ignore, 'g'), '');
	return string.replace(/_/g, ' ').replace(/\b[a-z]/g,function(f){return f.toUpperCase();});
}