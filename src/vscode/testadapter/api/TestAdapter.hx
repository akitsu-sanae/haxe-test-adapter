package vscode.testadapter.api;

import js.lib.Promise.Thenable;
import vscode.testadapter.api.event.TestEvent;
import vscode.testadapter.api.event.RetireEvent;
import vscode.testadapter.api.event.TestLoadEvent;

typedef TestAdapter = {
	/**
		The workspace folder that this test adapter is associated with (if any).
		There is usually one test adapter per workspace folder and testing framework.
	**/
	var workspaceFolder:vscode.WorkspaceFolder;

	/**
		Start loading the definitions of tests and test suites.
		Note that the Test Adapter should also watch source files and the configuration for changes and
		automatically reload the test definitions if necessary (without waiting for a call to this method).
		@returns A promise that is resolved when the adapter finished loading the test definitions.
	**/
	function load():Thenable<Void>;

	/**
		Run the specified tests.
		@param tests An array of test or suite IDs. For every suite ID, all tests in that suite are run.
		@returns A promise that is resolved when the test run is completed.
	**/
	function run(tests:Array<String>):Thenable<Void>;

	/**
		Run the specified tests in the debugger.
		@param tests An array of test or suite IDs. For every suite ID, all tests in that suite are run.
		@returns A promise that is resolved when the test run is completed.
	**/
	function debug(tests:Array<String>):Thenable<Void>;

	/**
		Stop the current test run.
	**/
	function cancel():Void;

	/**
		This event is used by the adapter to inform the Test Explorer (and other Test Controllers)
		that it started or finished loading the test definitions.
	**/
	function tests():Event<TestLoadEvent>;

	/**
		This event is used by the adapter during a test run to inform the Test Explorer
		(and other Test Controllers) about a test run and tests and suites being started or completed.
		For example, if there is one test suite with ID `suite1` containing one test with ID `test1`,
		a successful test run would emit the following events:
		```
		{ type: 'started', tests: ['suite1'] }
		{ type: 'suite', suite: 'suite1', state: 'running' }
		{ type: 'test', test: 'test1', state: 'running' }
		{ type: 'test', test: 'test1', state: 'passed' }
		{ type: 'suite', suite: 'suite1', state: 'completed' }
		{ type: 'finished' }
		```
	**/
	function testStates():Event<TestEvent>;

	/**
		This event can be used by the adapter to inform the Test Explorer about tests whose states
		are outdated.
		This is usually sent directly after a `TestLoadFinishedEvent` to specify which tests may
		have changed. Furthermore, it should be sent when the source files for the application
		under test have changed.
		This will also trigger a test run for those tests that have been set to "autorun" by the
		user and which are retired by this event.
		If the adapter does not implement this event then the Test Explorer will automatically
		retire (and possibly autorun) all tests after each `TestLoadFinishedEvent`.
	**/
	function retire():Event<RetireEvent>;

	/**
		@deprecated This event can be used by the adapter to trigger a test run for all tests that have
		been set to "autorun" in the Test Explorer.
	**/
	function autorun():Event<Void>;
}
