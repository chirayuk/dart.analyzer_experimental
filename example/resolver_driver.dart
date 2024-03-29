#!/usr/bin/env dart

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer_experimental/src/generated/java_io.dart';
import 'package:analyzer_experimental/src/generated/source_io.dart';
import 'package:analyzer_experimental/src/generated/ast.dart';
import 'package:analyzer_experimental/src/generated/sdk.dart';
import 'package:analyzer_experimental/src/generated/element.dart';
import 'package:analyzer_experimental/src/generated/engine.dart';

import 'dart:io';

main() {
  print('working dir ${new File('.').fullPathSync()}');

  var args = new Options().arguments;
  if (args.length != 2) {
    print('Usage: resolve_driver [path_to_sdk] [file_to_resolve]');
    exit(0);
  }

  JavaSystemIO.setProperty("com.google.dart.sdk", args[0]);
  DartSdk sdk = DartSdk.defaultSdk;

  AnalysisContext context = AnalysisEngine.instance.createAnalysisContext();
  context.sourceFactory = new SourceFactory.con2([new DartUriResolver(sdk), new FileUriResolver()]);
  Source source = new FileBasedSource.con1(context.sourceFactory, new JavaFile(args[1]));
  //
  ChangeSet changeSet = new ChangeSet();
  changeSet.added(source);
  context.applyChanges(changeSet);
  LibraryElement libElement = context.getLibraryElement(source);
  print("libElement: $libElement");

  CompilationUnit resolvedUnit = context.resolve(source, libElement);
  var visitor = new _ASTVisitor();
  resolvedUnit.accept(visitor);
}

class _ASTVisitor extends GeneralizingASTVisitor {
  visitNode(ASTNode node) {
    String text = '${node.runtimeType} : <"${node.toString()}">';
    if (node is SimpleIdentifier) {
      Element element = node.element;
      if (element != null) {
        text += " element: ${element.runtimeType}";
        LibraryElement library = element.library;
        if (library != null) {
          text += " from ${element.library.definingCompilationUnit.source.fullName}";
        }
      }
    }
    print(text);
    return super.visitNode(node);
  }
}

