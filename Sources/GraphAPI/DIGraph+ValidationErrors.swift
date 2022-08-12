//
//  DIGraph+ValidationErrors.swift
//  DITranquillity
//
//  Created by Alexander Ivlev on 03.07.2020.
//  Copyright © 2020 Alexander Ivlev. All rights reserved.
//

extension DIGraph {

  // MARK: - not initialize

  func log_canNotInitializePrototype(_ vertex: DIVertex, from fromVertex: DIVertex, optional: Bool) {
    let logLevel = optional ? DILogLevel.warning : DILogLevel.error
    log(logLevel, msg: "No initialization method for \(vertex.description). Reference to this component was found in \(fromVertex.description).")
  }

  func log_canNotInitializeObjectGraphWithoutCycle(_ vertex: DIVertex, from fromVertex: DIVertex, optional: Bool) {
    let logLevel = optional ? DILogLevel.warning : DILogLevel.error
    log(logLevel, msg: "No initialization method for \(vertex.description). Reference to this component was found in \(fromVertex.description).")
  }

  func log_canNotInitializeObjectGraphWithCycle(_ vertex: DIVertex, from fromVertex: DIVertex, optional: Bool) {
    let logLevel = optional ? DILogLevel.info : DILogLevel.warning
    log(logLevel, msg: "No initialization method for \(vertex.description). This component can be created using `inject(into:...` or from storyboard. Otherwise it's incorrect. Reference to this component was found in \(fromVertex.description).")
  }

  func log_canNotInitializeCached(_ vertex: DIVertex, from fromVertex: DIVertex) {
    log(.info, msg: "No initialization method for \(vertex.description). This component can be created using `inject(into:...` or from storyboard. After initial creation it will be cached. Reference to this component was found in \(fromVertex.description).")
  }

  func log_canNotInitialize(_ vertex: DIVertex) {
    log(.info, msg: "No initialization method for \(vertex.description). This component can be created using `inject(into:...` or from storyboard. Otherwise it's incorrect.")
  }

  func log_canNotInitializeCached(_ vertex: DIVertex) {
    log(.info, msg: "No initialization method for \(vertex.description). This component can be created using `inject(into:...` or from storyboard. After initial creation it will be cached.")
  }

  // MARK: - ambiguity
  func log_ambiguityReference(from fromVertex: DIVertex, for type: DIAType, candidates: [DIVertex], optional: Bool) {
    let logLevel = optional ? DILogLevel.warning : DILogLevel.error
    log(logLevel, msg: "More than one candidate found while trying to create an object for type: \(type) in \(fromVertex.description). Candidates: \(candidates.map { $0.description })")
  }

  // MARK: - reachibility
  func log_invalidReferenceOptional(from fromVertex: DIVertex, on type: DIAType) {
    log(.warning, msg: "Invalid reference in \(fromVertex.description), because couldn't find component type: Optional<\(type)>")
  }

  func log_invalidReferenceMany(from fromVertex: DIVertex, on type: DIAType) {
      log(.warning, msg: "Invalid reference in \(fromVertex.description), because couldn't find component type: Array<\(type)>")
  }

  func log_invalidReference(from fromVertex: DIVertex, on type: DIAType) {
      log(.error, msg: "Invalid reference in \(fromVertex.description), because couldn't find component type: \(type)")
  }

  // MARK: - cycle
  func log_cycleAnyInitEdges(vertices: [DIVertex], edges: [DIEdge]) {
    let cycleDescriptionMaker = { makeCycleDescription(vertices: vertices, edges: edges) }
    log(.error, msg: "A cycle consisting of init methods only was found. Break the cycle by substituting init method injection with property injection: \(cycleDescriptionMaker())")
  }

  func log_cycleNoHaveBreakPoint(vertices: [DIVertex], edges: [DIEdge]) {
    let cycleDescriptionMaker = { makeCycleDescription(vertices: vertices, edges: edges) }
    log(.error, msg: "A cycle without break points was found. Break the cycle using `.injection(cycle: true...`: \(cycleDescriptionMaker())")
  }

  func log_cycleAnyVerticesPrototype(vertices: [DIVertex], edges: [DIEdge]) {
    let cycleDescriptionMaker = { makeCycleDescription(vertices: vertices, edges: edges) }
    log(.error, msg: "A cycle with all components having a `prototype` lifetime was found. Objects in this cycle will keep being created indefinitely. Change lifetime to 'objectGraph' or other. Cycle description: \(cycleDescriptionMaker())")
  }

  func log_cycleHavePrototype(vertices: [DIVertex], edges: [DIEdge]) {
    let cycleDescriptionMaker = { makeCycleDescription(vertices: vertices, edges: edges) }
    log(.warning, msg: "A cycle with components having a 'prototype' lifetime was found. This could cause problems, if resolve starts from a 'prototype' component. You can change lifetime to 'objectGraph' or ignore the warning. Cycle description: \(cycleDescriptionMaker())")
  }

  func log_cycleHaveInvariantLifetimes(vertices: [DIVertex], edges: [DIEdge]) {
    let cycleDescriptionMaker = { makeCycleDescription(vertices: vertices, edges: edges) }
    log(.warning, msg: "Found a cycle where is it components have different lifetimes. This cycle can make incorrect. If start resolve from `prototype`/`objectGraph` you can reference from `perContainer`/`perRun`/`single` on other object because there is an old resolve in cache. Cycle description: \(cycleDescriptionMaker())")
  }
}

fileprivate func makeCycleDescription(vertices: [DIVertex], edges: [DIEdge]) -> String {
  var vertexDescriptions = vertices.map { $0.description }
  guard let firstDescription = vertexDescriptions.first else {
    return ""
  }
  vertexDescriptions.append(firstDescription)
  return vertexDescriptions.joined(separator: " -> ")
}
