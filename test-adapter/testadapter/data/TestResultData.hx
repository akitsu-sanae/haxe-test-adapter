package testadapter.data;

import haxe.Timer;
import haxe.io.Path;
#if (sys || nodejs)
import haxe.Json;
import json2object.JsonParser;
import sys.FileSystem;
import sys.io.File;
#end
import testadapter.data.Data;

class TestResultData {
	public static inline var RESULT_FOLDER:String = ".unittest";
	public static inline var RESULT_FILE:String = "testResults.json";
	public static inline var LAST_RUN_FILE:String = "lastRun.json";
	public static inline var ROOT_SUITE_NAME:String = "root";

	var suiteData:SuiteTestResultData;
	var fileName:String;
	var baseFolder:String;

	public function new(?baseFolder:String) {
		this.baseFolder = baseFolder;
		fileName = getTestDataFileName(baseFolder);
		init();
	}

	public function addPass(className:String, name:String, location:String, executionTime:Float) {
		addTestResult(className, name, location, executionTime, Success, null);
	}

	public function addFail(className:String, name:String, location:String, executionTime:Float, errorText:String) {
		addTestResult(className, name, location, executionTime, Failure, errorText);
	}

	public function addError(className:String, name:String, location:String, executionTime:Float, errorText:String) {
		addTestResult(className, name, location, executionTime, Error, errorText);
	}

	public function addIgnore(className:String, name:String, location:String) {
		addTestResult(className, name, location, 0, Ignore, null);
	}

	public function addTestResult(className:String, name:String, location:String, executionTime:Float, state:SingleTestResultState, errorText:String) {
		var pos = TestPosCache.getPos(location);
		var line:Null<Int> = null;
		if (pos != null) {
			line = pos.line;
		}
		for (data in suiteData.classes) {
			if (data.name == className) {
				for (test in data.tests) {
					if (test.location == location) {
						test.location = location;
						test.executionTime = executionTime;
						test.state = state;
						test.timestamp = Timer.stamp();
						test.errorText = errorText;
						test.line = line;
						saveData();
						return;
					}
				}
				data.tests.push({
					name: name,
					location: location,
					executionTime: executionTime,
					state: state,
					errorText: errorText,
					timestamp: Timer.stamp(),
					line: line
				});
				saveData();
				return;
			}
		}
		suiteData.classes.push({
			name: className,
			tests: [
				{
					name: name,
					location: location,
					executionTime: executionTime,
					state: state,
					errorText: errorText,
					timestamp: Timer.stamp(),
					line: line
				}
			],
			pos: TestPosCache.getPos(className)
		});
		saveData();
	}

	function init() {
		#if (nodejs || sys)
		if (!FileSystem.exists(fileName)) {
			FileSystem.createDirectory(RESULT_FOLDER);
			suiteData = {name: ROOT_SUITE_NAME, classes: []};
			return;
		}
		#end
		if (!TestFilter.hasFilter()) {
			#if (nodejs || sys)
			var lastRun:String = Path.join([RESULT_FOLDER, LAST_RUN_FILE]);
			try {
				FileSystem.deleteFile(lastRun);
			} catch (e:Any) {}
			FileSystem.rename(fileName, lastRun);
			#end
			suiteData = {name: ROOT_SUITE_NAME, classes: []};
		} else {
			suiteData = loadData(baseFolder);
		}
	}

	function saveData() {
		#if (sys || nodejs)
		File.saveContent(fileName, Json.stringify(suiteData, null, "    "));
		#end
	}

	public static function loadData(?baseFolder:String):SuiteTestResultData {
		#if (sys || nodejs)
		var dataFile:String = getTestDataFileName(baseFolder);
		if (!FileSystem.exists(dataFile)) {
			return {name: ROOT_SUITE_NAME, classes: []};
		}
		var content:String = File.getContent(dataFile);

		var parser = new JsonParser<SuiteTestResultData>();
		return parser.fromJson(content, dataFile);
		#end
		return {name: ROOT_SUITE_NAME, classes: []};
	}

	public static function getTestDataFileName(?baseFolder:String):String {
		return Path.join([baseFolder, RESULT_FOLDER, RESULT_FILE]);
	}
}
