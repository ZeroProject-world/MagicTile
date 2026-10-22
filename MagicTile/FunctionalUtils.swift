//
//  FunctionalUtils.swift
//  MagicTile
//
//  Created by Hongyu on 6/5/19.
//  Copyright © 2019 Cyandev. All rights reserved.
//

func bind<T, U>(_ x: T, _ closure: (T) -> U) -> U {
    return closure(x)
}
