//
//  Queue.swift
//  BM
//
//  Created by Карпец Андрей on 30.08.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import Foundation

class Queue<Value> {

	var count: Int {
		return values.count - headIndex
	}

	var isEmpty: Bool {
		return count == 0
	}

	private var values: [Value]

	private var headIndex = 0

	init(values: [Value] = []) {
		self.values = values
	}

	func enqueue(value: Value) {
		values.append(value)
	}

	func dequeue() -> Value? {
		guard !values.isEmpty && headIndex < values.count else {
			return nil
		}

		let value = values[headIndex]
		headIndex += 1

		let freeSlots = values.count - headIndex
		let percetage = Double(freeSlots) / Double(values.count)

		if percetage > 0.4 && values.count > 40 {
			values.removeFirst(headIndex)
			headIndex = 0
		}

		return value
	}
}
