# StoryTeller
A logging framework that promotes following data rather than functionality in logs.

### WTF - Another logging framework!!!

Yep. Another one. But with a difference ...

The idea that drives Story Teller is quite simple: ***To debug an application, developers need to see the threads of data as they weave their way through the code.***

Other logging frameworks use a very crass shotgun approach (IMHO). The developer adds log statements to the code based on the perceived severity of of the data being logged. Later when debugging, the develope then has to derive a logging criteria based on a guesstimate of severity and location, hoping that the logs show the right information. More often that not, a large amount of output is produced which requires significant effort to troll through. Essentially the focus of these logging frameworks is based around two questions: *How important is the imformation and where in the source code is it?* These are the wrong questions. Simply because the data that drives the app is not relevant to either of these concepts.

Story Teller bases it's logging around a simpler and more important question: ***What is this about?*** and concentrates on answering that question. It does it by keying the logging based on the data. This enables it to then report based on the targetted data and to provide very concise logs which only contain output related to the problem at hand.

## Setup

### Carthage

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This project can be dynamically included using [Carthage](https://github.com/Carthage/Carthage). This is recommended if you are using iOS8+.

Simple create a  file called ***CartFile*** in the root of your project and add a line of text like this:

```
github "drekka/StoryTeller" >= 0.1
```
fire up a command line and execute from our projects root directory:

```
carthage bootstrap
```

This will download and compile Story Teller into a framework in *<project-root>/Carthage/Build/iOS/StoryTeller.framework*.

Then simply add this framework as you would any other.

### Cocoapods

At the moment I don't support [Cocoapods](https://cocoapods.org) because I regard it as as hacky poor quality solution. And I don't use it on my personal projects. I have created a posspec in the root of Story Teller, but so far it doesn't pass the pod lint tests and typically with any Ruby hack projects, is giving errors that make no sense. I'll get around to supporting it one day. But it's not something I use. Feel free to figure it out if you want.

### Submodules or Manual includes

Another fine way to include Story Teller is to use [Git Submodules](https://chrisjean.com/git-submodules-adding-using-removing-and-updating/). Whilst more technical in nature, it gves you the best control of the software. Use the following URL for your submodule or if you want to manually check Story Teller out:

[https://github.com/drekka/StoryTeller.git]()

Note: that you can also use the `--submodules` option of Carthage to create a dependency as a submodule.

## Adding logging to your code

Story Teller has one basic logging statement:

```objectivec
log(<key>, <message-template>, <args ...>); 
```
This looks very similar to other logging frameworks. Except that they would either having `key` replaced with a severity level, or have multiple statements such as `logDebug`, `logInfo`, etc.

Story Teller's ***Key*** is the important differentiator. ***It can be anything you want!*** 

The idea though, *is that it is an identifier that you can later use to trace data through the system.* This is where Story Teller's strength is. The key might be an account number, a user id, a class, or any object you want to be able to search on when debugging. It could be relevant to the application's config, a users account, the graphics subsystem. Whatever makes sense in your app. Here's an example:

```objectivec
log(user.id, "User %@ is logging", user.id);
```

This statement will log based on the user's ID. Which means that we can target specific users when producing log reports.

### What if I don't have an accessible key?

Often you might want to be logging based on something like an account number, but be in some method that doesn't have that account number accessible. So how do you log it?

Story Teller has the concept of **Key Scopes**. This is where you can tell it that any logging statements for a particular range of code are regarded as being also under a specific key, even if the log statements do not use that key. Here's an example:

```objectivec
log(user.id, "User %@ is logging", user.id);
startScope(user.id);
/// ...  do stuff
log(account.id, "User %@'s account: %@", user.id, account.id); 
[self goDoSomethingWithAccount:account];
```

So when reporting based on user, the second log statement (account.id) will also be printed because it's within the scope of user.

Scopes follow the normal Objective-C rules for variable scopes. When enabled they will continue until the end of the current variable scope. Normally this is the end of the current method, loop or if statement. However Story Teller's scopes also include any code called. So any logging within a method or API is also included with the scope. This enables logging across a wide range of classes to be accessed using one key without having to specifically pass that key around.  So in the above example, any logging with in `goDoSomethingWithAccount:` will also be logged when logging for the user.

## Turning on a log

So when you want to then debug a problem, the first thing you need to do is establish what has the problem. Is it a specific account? user? etc.

### On startup

Story Teller uses a set of options which it obtains via this process on startup:

1. A default setup is first created with no logging active.
2. Story Teller then searches all bundles in the app for a file called ***StoryTellerConfig.json***. If found this file is read and the base config is updated with any settings it contains.
3. Finally the process is checked and if any of the arguments set on the process match known keys in the config, then those values are updated.

The basic idea is that you can add a ***StoryTellerConfig.json*** file to your app to provide the general config you want to run with, and then during development you can override at will by setting arguments in XCode's scheme for your app.

### Programmatically

You can also programmically enable and disable logging as well. To enable logging, use this statement:

```objectivec
startLogging(<key>);
```

and of course:

```objectivec
stopLogging(<key>);
```

### Config settings

The following is a list of config settings:

Key  | Value
------------- | -------------
logAll | Enables every log statement regardless of it's key. Useful for bugging but might produce a lot of output.
LogRoots | Similar to *logAll* except that only top level log statements are activated. Useful for getting a high level view of whats occuring.
activeLogs | A comma separated list of keys to activate. This is the main setting for turning on logging.
loggerClass | If you want to set a different class for the, use this setting to specify the class. The class must implement `STLogger` and have a no-arg constructor. You only need to put the class name in this setting. Story Teller will handle the rest.

### Log matchers (Planned functionality!)

When defining keys to search for when logging, you can also defined more flexible criteria that just specific values. For example, to log where the users account has a balance > $500. 

## Execution blocks

Story Teller has another trick up it's sleeve. Often we want to run a set of statements to assemble some data before logging or even to log a number of statements at once. With other frameworks we have to manually add some boiler plate around the statements to make sure they are not always being executed. Story Teller has a statement built specifically for this purpose:

```objectivec
executeBlock(<key>, ^(id key) {
     // Statements go here.
});
``` 

The block will only be executed if they currently active logging matches the key.

## Performance

Performance is a key issue for loggers because they are trying to avoid slowing down the program. Especially when not logging. Story Teller has made every attempt to keep things as fast as possible. Whilst the sophistocation of it's criteria may mean that it cannot compete with some of the more simpler frameworks, given todays processor speeds this may not be an issue. 


