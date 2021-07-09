
//ここから下は触らなくてもOK
//(namespaceは使わなくても動作します)
YAHOO.namespace('tato');//カスタマイズした関数など用に名前空間を用意しておきます
YAHOO.tato.tree = function(id) {

  this.tree = new YAHOO.widget.TreeView(id); //treeDiv1は表示するDIVのID名です
  
  //Tree描画  by Array
  YAHOO.tato.tree.prototype.mkTreeByArray = function (treeData,treeNode){
    if(!treeNode)treeNode = this.tree.getRoot(); 
    for(var i in treeData){
      if(!(treeData[i][0]=="_open"||treeData[i][0]=="_close"||treeData[i][0]=="_load")){
      
       if(treeData[i][0]){
        var tmpNode = new YAHOO.widget.TextNode("" + treeData[i][0],treeNode, false);
        
        if(typeof treeData[i][1] == "string"){ tmpNode.href= treeData[i][1]; tmpNode.target= "sample"; }
        else if(typeof treeData[i][1] == "object"){
          this.mkTreeByArray(treeData[i][1],tmpNode); 
          var swt = treeData[i][1][0][0];
          switch(swt){
            case    "_open"  : tmpNode.expand();break;
            case    "_close" : tmpNode.collapse();break;
            case    "_load"  : YAHOO.tato.loadTreeData(this,tmpNode,treeData[i]);break;
            dafault :tmpNode.expand();break;
          }
        }
       }
      }
    }
    this.tree.draw();
  }
}

YAHOO.tato.loadTreeData = function(oj,tmpNode,treeDataFrg){
  if(!!YAHOO.util.Connect){
      if(treeDataFrg[1][0][1]){
        tmpNode.method=(treeDataFrg[1][0][1].method)?treeDataFrg[1][0][1].method:"GET";
        tmpNode.url=(treeDataFrg[1][0][1].url)?treeDataFrg[1][0][1].url:"";
      }
      tmpNode.setDynamicLoad(
        function (node,onCompleteCallback ){
          tmpNode =new YAHOO.widget.Node("",tmpNode.pearent,false);
          var delay = YAHOO.tato.loadTreeData.delay ;
          if(YAHOO.tato.loadTreeData.delay>0)setTimeout(onCompleteCallback,delay);
          else onCompleteCallback();
        }
      );
      
      oj.tree.onExpand= function(node) {
        if(tmpNode.label==node.label)
        if(node.children.length<=0){
          YAHOO.util.Connect.asyncRequest(node.method,node.url,{
            argument:{'node':node},scope:oj,success: getResponse
          },null);
        }
      }
      getResponse= function(oj){//alert(oj.argument.node.hasChildren(true))
        data = eval(oj.responseText);
        this.mkTreeByArray (data,oj.argument.node); 
      } 
  }
}

YAHOO.tato.loadTreeData.delay = 0;