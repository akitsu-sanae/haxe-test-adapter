package unittesthelper.munit;

import massive.munit.ITestResultClient;
import massive.munit.TestResult;
import unittesthelper.data.TestPos;
import unittesthelper.data.TestPosCache;
import unittesthelper.data.TestResultData;
import unittesthelper.data.SingleTestResultState;

class TestAdapterResultClient implements IAdvancedTestResultClient implements ICoverageTestResultClient {
	var testData:TestResultData;

	@:isVar public var completionHandler(get, set):ITestResultClient->Void;
	public var id(default, null):String;

	public function new(?baseFolder:String) {
		testData = new TestResultData(baseFolder);
	}

	function get_completionHandler():ITestResultClient->Void {
		return completionHandler;
	}

	function set_completionHandler(value:ITestResultClient->Void):ITestResultClient->Void {
		completionHandler = value;
		return completionHandler;
	}

	public function addPass(result:TestResult) {
		testData.addPass(result.className, result.name, result.location, result.executionTime);
	}

	public function addFail(result:TestResult) {
		var errorText:String = "unknown";

		if (result.failure != null) {
			errorText = result.failure.message;
		}
		testData.addFail(result.className, result.name, result.location, result.executionTime, errorText);
	}

	public function addError(result:TestResult) {
		testData.addError(result.className, result.name, result.location, result.executionTime, '${result.error}');
	}

	public function addIgnore(result:TestResult) {
		testData.addIgnore(result.className, result.name, result.location);
	}

	@SuppressWarnings("checkstyle:Dynamic")
	public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float):Dynamic {
		if (completionHandler != null) {
			completionHandler(this);
		}
		return null;
	}

	public function setCurrentTestClass(className:String) {}

	public function setCurrentTestClassCoverage(result:CoverageResult) {}

	public function reportFinalCoverage(?percent:Float = 0, missingCoverageResults:Array<CoverageResult>, summary:String, ?classBreakdown:String = null,
		?packageBreakdown:String = null, ?executionFrequency:String = null) {}
}
