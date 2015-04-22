import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;

import mx.collections.ArrayCollection;

import spark.components.Image;
import spark.components.TextInput;

static private const HOLE:int = 0;
static private const BODY:int = 1;
static private const HEAD:int = 2;

static private const UP:int = 0;
static private const RIGHT:int = 1;
static private const DOWN:int = 2;
static private const LEFT:int = 3;

private var upList:Array = [7, 8, 9, 10, 11, 18, 26, 27, 28];
private var rightList:Array = [-19, -12, -10, -3, -2, -1, 6, 8, 17];
private var downList:Array = [-7, -8, -9, -10, -11, -18, -26, -27, -28];
private var leftList:Array = [-17, -8, -6, 1, 2, 3, 10, 12, 19];

private var leftRotateList:Array = [8,17,26,35,44,53,62,71,80,7,16,25,34,43,52,61,70,79,6,15,24,33,42,51,60,69,78,5,14,23,32,41,50,59,68,77,4,13,22,31,40,49,58,67,76,3,12,21,30,39,48,57,66,75,2,11,20,29,38,47,56,65,74,1,10,19,28,37,46,55,64,73,0,9,18,27,36,45,54,63,72];
private var rightRotateList:Array = [72,63,54,45,36,27,18,9,0,73,64,55,46,37,28,19,10,1,74,65,56,47,38,29,20,11,2,75,66,57,48,39,30,21,12,3,76,67,58,49,40,31,22,13,4,77,68,59,50,41,32,23,14,5,78,69,60,51,42,33,24,15,6,79,70,61,52,43,34,25,16,7,80,71,62,53,44,35,26,17,8];

private var file:File;
private var fileNameArray:Array;
private var fileContentArray:Array;
private var selectingPath:TextInput;
private var headSource:String = "assets/hitHead.png";
private var bodySource:String = "assets/hitBody.png";
private var holeSource:String = "assets/hitHole.png";
private var darkSource:String = "assets/status.jpg";

private var headList:Array;
private var directionList:Array;
private var hardData:ArrayCollection = new ArrayCollection([{id:"0", name:"容易"},{id:"1", name:"普通"},{id:"2", name:"困难"}]);
private var direcitionData:ArrayCollection = new ArrayCollection([{id:"0", name:"上"},{id:"1", name:"右"},{id:"2", name:"下"},{id:"3", name:"左"}]);
private var mapData:Array;
private var rotateData:Array;
private var statusData:Array;
private var rotateStatus:Array;

private function init():void
{
	mapData = new Array();
	mapData.length = 81;
	statusData = new Array();
	statusData.length = 81;
	rotateData = new Array();
	rotateData.length = 81;
	rotateStatus = new Array();
	rotateStatus.length = 81;
	headList = new Array();
	headList.length = 3;
	directionList = new Array();
	directionList.length = 3;
	
	file = new File();
	file.addEventListener(Event.SELECT, onDirSelected);
	
	fileNameArray = [];
	fileContentArray = [];
	
	JSONInput.dataProvider = new ArrayCollection(LocalSaveManager.getInputDir());
	JSONOutput.dataProvider = new ArrayCollection(LocalSaveManager.getOutputDir());
	
	newMap();
	this.addEventListener(MouseEvent.CLICK, onMapClick);
	Scan0.addEventListener(MouseEvent.CLICK, onClick);
	AddPlane1.addEventListener(MouseEvent.CLICK, onClick);
	AddPlane2.addEventListener(MouseEvent.CLICK, onClick);
	AddPlane3.addEventListener(MouseEvent.CLICK, onClick);
	LightAll.addEventListener(MouseEvent.CLICK, onClick);
	OutputJson.addEventListener(MouseEvent.CLICK, onClick);
	InputJson.addEventListener(MouseEvent.CLICK, onClick);
	NewMap.addEventListener(MouseEvent.CLICK, onClick);
	leftRotate.addEventListener(MouseEvent.CLICK, onClick);
	rightRotate.addEventListener(MouseEvent.CLICK, onClick);
}

protected function onDirSelected(event:Event):void
{
	selectingPath.text = file.nativePath;
}


private function onInputHead(num:int):Boolean
{
	var head:String;
	var direction:int;
	if(num == 1)
	{
		head = this["Plane" + 1].text;
		direction = this["Direction" + 1].selectedItem.id;
	}
	else if(num == 2)
	{
		head = this["Plane" + 2].text;
		direction = this["Direction" + 2].selectedItem.id;
	}
	else if(num == 3)
	{
		head = this["Plane" + 3].text;
		direction = this["Direction" + 3].selectedItem.id;
	}
	else
	{
		ErrorOutput.text = "无此飞机";
		return false;
	}
	if(head != "")
	{
		try
		{
			var headPos:int = int(head);
		}
		catch(e:Error)
		{
			ErrorOutput.text = "错误飞机头";
			return false;
		}
		if(mapData[headPos] != 0)
		{
			ErrorOutput.text = "飞机重叠";
			return false;
		}
		var bodyList:Array;
		bodyList = getDirectionList(direction);
		var length:int = bodyList.length;
		for (var i:int = 0; i < length; i++) 
		{
			if(mapData[headPos + bodyList[i]] != 0)
			{
				ErrorOutput.text = "飞机重叠";
				return false;
			}
		}
		switch (direction) {
			case UP:
				if(headPos > 54||(headPos%9)<2||(headPos%9)>6)
				{
					ErrorOutput.text = "飞机出格";
					return false;
				}
				else
				{
					ErrorOutput.text = "";
					return true;
				}
				break;
			case RIGHT:
				if(headPos < 18||(headPos%9)<3||headPos > 62)
				{
					ErrorOutput.text = "飞机出格";
					return false;
				}
				else
				{
					ErrorOutput.text = "";
					return true;
				}
				break;
			case DOWN:
				if(headPos < 27||(headPos%9)<2||(headPos%9)>6)
				{
					ErrorOutput.text = "飞机出格";
					return false;
				}
				else
				{
					ErrorOutput.text = "";
					return true;
				}
				break;
			case LEFT:
				if(headPos < 18||(headPos%9)>5||headPos > 62)
				{
					ErrorOutput.text = "飞机出格";
					return false;
				}
				else
				{
					ErrorOutput.text = "";
					return true;
				}
				break;
			default:
				ErrorOutput.text = "错误方向";
				return false;
		}
	}
	else
	{
		ErrorOutput.text = "请填写飞机头";
		return false;
	}
	return false;
}

private function onMapClick(e:MouseEvent):void
{
	var grid:Image = e.target.parent as Image;
	if(grid)
	{
		var i:int = int(grid.id.substr(5));
		if(statusData[i] == false)
		{
			setGridLight(i, true);
		}
		else
		{
			setGridLight(i, false);
		}
	}
}

private function onClick(e:MouseEvent):void
{
	switch (e.target)
	{
		case AddPlane1:
			if(onInputHead(1))
			{
				if(Plane1.text)
				{
					addOnePlane(1);
				}
			}
			break;
		
		case AddPlane2:
			if(onInputHead(2))
			{
				if(Plane2.text)
				{
					addOnePlane(2);
				}
			}
			break;
		
		case AddPlane3:
			if(onInputHead(3))
			{
				if(Plane3.text)
				{
					addOnePlane(3);
				}
			}
			break;
		
		case LightAll:
			setAllGridLight();
			break;
		
		case Scan0:
			selectingPath = JSONOutput.textInput;
			file.browseForOpen("选择需要解密的文件", [new FileFilter("txt", "*.txt"), new FileFilter("json", "*json")]);
			trace("选择路径");
			break;
		
		case Scan1:
			break;
		
		case OutputJson:
			output();
			break;
		
		case InputJson:
			input();
			break;
		
		case NewMap:
			newMap();
			break;
		
		case leftRotate:
			leftRotateMap();
			break;
		
		case rightRotate:
			rightRotateMap();
			break;
	}
}


private function addOnePlane(num:int):void
{
	removeOnePlane(num);
	var headInput:String;
	var direction:int;
	if(num == 1)
	{
		headInput = this["Plane" + 1].text;
		direction = this["Direction" + 1].selectedItem.id;
	}
	else if(num == 2)
	{
		headInput = this["Plane" + 2].text;
		direction = this["Direction" + 2].selectedItem.id;
	}
	else if(num == 3)
	{
		headInput = this["Plane" + 3].text;
		direction = this["Direction" + 3].selectedItem.id;
	}
	var head:int = int(headInput);
	var bodyList:Array;
	mapData[head] = 2;
	if(statusData[head] == 1)
	{
		setGridLight(head, true);
	}
	bodyList = getDirectionList(direction);
	var length:int = bodyList.length;
	for (var i:int = 0; i < length; i++) 
	{
		if(mapData[head + bodyList[i]] != 1)
		{
			mapData[head + bodyList[i]] = 1;
			if(statusData[head + bodyList[i]] == 1)
			{
				setGridLight(head + bodyList[i], true);
			}
		}
	}
	headList[num - 1] = head;
	directionList[num - 1] = direction;
}

private function removeOnePlane(num:int):void
{
	var head:int;
	var direction:int;
	head = headList[num - 1];
	direction = directionList[num - 1];
	if(head && direction)
	{
		var bodyList:Array;
		mapData[head] = 0;
		bodyList = getDirectionList(direction);
		var length:int = bodyList.length;
		for (var i:int = 0; i < length; i++) 
		{
			if(mapData[head + bodyList[i]] == 1)
			{
				mapData[head + bodyList[i]] = 0;
				if(statusData[head + bodyList[i]] == 1)
				{
					setGridLight(head + bodyList[i], true);
				}
			}
		}
	}
}

private function getDirectionList(direction:int):Array
{
	switch (direction)
	{
		case UP:
			return upList;
		case RIGHT:
			return rightList;
		case DOWN:
			return downList;
		case LEFT:
			return leftList;
	}
	return [];
}

//单个Grid的监听
private function setGridLight(grid:int, light:Boolean):void
{
	if(light)
	{
		switch(mapData[grid])
		{
			case HOLE:
				this["grid_" + grid].source = holeSource;
				break;
			
			case BODY:
				this["grid_" + grid].source = bodySource;
				break;
			
			case HEAD:
				this["grid_" + grid].source = headSource;
				break;
		}
		statusData[grid] = true;
	}
	else
	{
		this["grid_" + grid].source = darkSource;
		statusData[grid] = false;
	}
}

//处理状态的两个方法
private function newMap():void
{
	for (var i:int = 0; i < 81; i++) 
	{
		mapData[i] = 0;
		setGridLight(i, false);
	}
	for(var j:int = 1; j < 4; j++)
	{
		this["Plane" + j].text = "";
	}
	ErrorOutput.text = "";	
}

private function setAllGridLight():void
{
	for (var i:int = 0; i < 81; i++) 
	{
		setGridLight(i, !statusData[i]);
	}
}

private function leftRotateMap():void
{
	for(var i:int = 0; i < 81; i++)
	{
		rotateData[i] = mapData[leftRotateList[i]];
		rotateStatus[i] = statusData[leftRotateList[i]];
	}
	newMap();
	for(var j:int = 0; j < 81; j++)
	{
		mapData[j] = rotateData[j];
		setGridLight(j, statusData[j]);
	}
	for(var k:int = 0; k < 3; k++)
	{
		var num:int = k + 1;
		this["Plane" + num].text = leftRotateList[headList[k]];
		if(this["Direction" + num].selectedItem.id + 1 < 0)
		{
			this["Direction" + num].selectedItem.id = 4
		}
		else
		{
			this["Direction" + num].selectedItem.id - 1;
		}
	}
}

private function rightRotateMap():void
{
	for(var i:int = 0; i < 81; i++)
	{
		rotateData[i] = mapData[rightRotateList[i]];
		rotateStatus[i] = statusData[rightRotateList[i]];
	}
	newMap();
	for(var j:int = 0; j < 81; j++)
	{
		mapData[j] = rotateData[j];
		setGridLight(j, statusData[j]);
	}
	for(var k:int = 0; k < 3; k++)
	{
		var num:int = k + 1;
		this["Plane" + num].text = rightRotateList[headList[k]];
		if(this["Direction" + num].selectedItem.id + 1 > 4)
		{
			//this["Direction" + num].selectedItem = direcitionData[0]
			this["Direction" + num].selectedItem.id = 0
		}
		else
		{
			this["Direction" + num].selectedItem.id += 1;
			//this["Direction" + num].selectedItem = direcitionData[]
		}
	}
}

//文件生成和加载
private function input():void
{
	var data:JSON;
	var stream:FileStream = new FileStream();
	var finalDirectory:File = new File(JSONInput.textInput.text);
	stream.open(finalDirectory, FileMode.READ);
	if (stream.bytesAvailable)
	{
		
	}
	stream.close();
}

private function output():void
{
	var stream:FileStream = new FileStream();
	var finalDirectory:File = new File(JSONOutput.textInput.text);
	stream.open(finalDirectory, FileMode.WRITE);
	var appendJson:String;
	appendJson = "{" + "\n\t\t" +
		"\"" + "name" + "\"" + ":" + "\"" + MapName.text +  "\"" + "," + "\n\t\t" +
		"\"" + "step" + "\"" + ":" + "[" + Step1.text + "," + Step2.text + "," + Step3.text + "]" + "," + "\n\t\t" +
		"\"" + "type" + "\"" + ":" + "\"" + HardList.selectedItem.id +  "\"" + "," + "\n\t\t" +
		"\"" + "head" + "\"" + ":" + "[" + Plane1.text + "," + Plane2.text + "," + Plane3.text + "]" + "," + "\n\t\t" +
		"\"" + "direction" + "\"" + ":" + "[" + Direction1.selectedItem.id + "," + Direction2.selectedItem.id + "," + Direction3.selectedItem.id + "]" + "," + "\n\t\t" +
		"\"" + "light" + "\"" + ":" + "[" ;
	var num:int = 0;
	for(var i:int = 0; i<statusData.length; i++)
	{
		if(statusData[i] == 1)
		{
			if(num==0)
			{
				appendJson += i.toString();
				num++;
			}
			else
			{
				appendJson += "," + i;
				num++;
			}
		}
	}
	appendJson+="]" + "\n" + "},"; 
	stream.writeUTFBytes(appendJson);
	stream.close();
	var collection:ArrayCollection = JSONOutput.dataProvider as ArrayCollection;
	LocalSaveManager.saveOutputDir(collection.source);
}

