//
//  Reducer.swift
//  ScaleStateApp
//
//  Created by Mushthak Ebrahim on 14/01/25.
//


typealias Reducer<State, Action, Environment> = (State, Action, Environment) async -> (Action?, State) 
