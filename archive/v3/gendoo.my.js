
function allcheck(targetForm,flag){
  for(n=0;n<=targetForm.length-1;n++){
    if(targetForm.elements[n].type == "checkbox"){
      targetForm.elements[n].checked = flag;
    }
  }
}