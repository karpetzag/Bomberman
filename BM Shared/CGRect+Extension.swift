//
//  CGRect+Extension.swift
//  BM
//
//  Created by Карпец Андрей on 18.07.2020.
//  Copyright © 2020 AK. All rights reserved.
//

import Foundation
#if !os(macOS)
import UIKit
#endif

extension CGRect {

	var topLeft: CGPoint {
		CGPoint(x: minX, y: maxY)
	}

	var topRight: CGPoint {
		CGPoint(x: maxX, y: maxY)
	}

	var bottomLeft: CGPoint {
		CGPoint(x: minX, y: minY)
	}

	var bottomRight: CGPoint {
		CGPoint(x: maxX, y: minY)
	}

	func pointsForDirection(_ direction: Direction) -> [CGPoint] {
		switch direction {
		case .down: return [bottomLeft, bottomRight]
		case .left: return [bottomLeft, topLeft]
		case .up: return [topRight, topLeft]
		case .right: return [topRight, bottomRight]
		}
	}
}
