//
//  GlukloaderIcon.m
//  glukloader
//
//  Created by Alexandre Normand on 2014-07-27.
//  Copyright (c) 2014 Glukit. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "GlukloaderIcon.h"


@implementation GlukloaderIcon

#pragma mark Cache

static NSColor* _dropletColor = nil;
static NSColor* _waveColor = nil;
static NSColor* _waterColor = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _dropletColor = [NSColor colorWithCalibratedRed: 0.121 green: 0.482 blue: 0.839 alpha: 1];
    _waveColor = [NSColor colorWithCalibratedRed: 0.053 green: 0.218 blue: 0.529 alpha: 1];
    _waterColor = [NSColor colorWithCalibratedRed: 0.621 green: 0.832 blue: 1 alpha: 0.505];

}

#pragma mark Colors

+ (NSColor*)dropletColor { return _dropletColor; }
+ (NSColor*)waveColor { return _waveColor; }
+ (NSColor*)waterColor { return _waterColor; }

#pragma mark Drawing Methods

+ (void)drawIconWithIsConnected: (BOOL)isConnected isSyncInProgress: (BOOL)isSyncInProgress;
{
    //// General Declarations
    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;

    //// Color Declarations
    NSColor* dropletColorSync = [NSColor colorWithCalibratedHue: GlukloaderIcon.dropletColor.hueComponent saturation: 0.7 brightness: GlukloaderIcon.dropletColor.brightnessComponent alpha: GlukloaderIcon.dropletColor.alphaComponent];
    NSColor* dropletColorDisconnected = [NSColor colorWithCalibratedHue: GlukloaderIcon.dropletColor.hueComponent saturation: 0.4 brightness: GlukloaderIcon.dropletColor.brightnessComponent alpha: GlukloaderIcon.dropletColor.alphaComponent];
    NSColor* waveColorSync = [GlukloaderIcon.waveColor highlightWithLevel: 0.8];
    NSColor* waveColorDisconnected = [NSColor colorWithCalibratedHue: GlukloaderIcon.waveColor.hueComponent saturation: 0.8 brightness: GlukloaderIcon.waveColor.brightnessComponent alpha: GlukloaderIcon.waveColor.alphaComponent];
    NSColor* waterColorSync = [NSColor colorWithCalibratedHue: GlukloaderIcon.waterColor.hueComponent saturation: 0.3 brightness: GlukloaderIcon.waterColor.brightnessComponent alpha: GlukloaderIcon.waterColor.alphaComponent];
    NSColor* waterColorDisconnected = [GlukloaderIcon.waterColor highlightWithLevel: 0.8];

    //// Variable Declarations
    NSColor* computerDropletColor = isConnected && isSyncInProgress ? dropletColorSync : (isConnected ? GlukloaderIcon.dropletColor : dropletColorDisconnected);
    NSColor* computedWaveColor = isConnected && isSyncInProgress ? waveColorSync : (isConnected ? GlukloaderIcon.waveColor : waveColorDisconnected);
    NSColor* computedWaterColor = isConnected && isSyncInProgress ? waterColorSync : (isConnected ? GlukloaderIcon.waterColor : waterColorDisconnected);

    //// Droplet
    {
        [NSGraphicsContext saveGraphicsState];
        CGContextTranslateCTM(context, 2, 0);
        CGContextScaleCTM(context, 0.1, 0.1);



        //// Bezier Drawing
        NSBezierPath* bezierPath = NSBezierPath.bezierPath;
        [bezierPath moveToPoint: NSMakePoint(109.81, 53.64)];
        [bezierPath curveToPoint: NSMakePoint(95.49, 90.51) controlPoint1: NSMakePoint(109.45, 65.41) controlPoint2: NSMakePoint(100, 81.81)];
        [bezierPath curveToPoint: NSMakePoint(80.36, 160.26) controlPoint1: NSMakePoint(91.61, 98.02) controlPoint2: NSMakePoint(69.92, 152.27)];
        [bezierPath curveToPoint: NSMakePoint(13.27, 92.31) controlPoint1: NSMakePoint(79.67, 159.74) controlPoint2: NSMakePoint(32.57, 123.75)];
        [bezierPath lineToPoint: NSMakePoint(9.87, 86.23)];
        [bezierPath curveToPoint: NSMakePoint(14.65, 15.06) controlPoint1: NSMakePoint(6.47, 80.14) controlPoint2: NSMakePoint(-13.03, 42.65)];
        [bezierPath curveToPoint: NSMakePoint(60.28, 0) controlPoint1: NSMakePoint(26.71, 3.03) controlPoint2: NSMakePoint(39.89, 0)];
        [bezierPath curveToPoint: NSMakePoint(109.81, 53.64) controlPoint1: NSMakePoint(70.75, -0) controlPoint2: NSMakePoint(111.18, 9.19)];
        [bezierPath closePath];
        [bezierPath setMiterLimit: 4];
        [computerDropletColor setFill];
        [bezierPath fill];


        //// Bezier 2 Drawing
        NSBezierPath* bezier2Path = NSBezierPath.bezierPath;
        [bezier2Path moveToPoint: NSMakePoint(107.04, 59.81)];
        [bezier2Path curveToPoint: NSMakePoint(107.89, 59.69) controlPoint1: NSMakePoint(107.67, 59.72) controlPoint2: NSMakePoint(107.39, 59.76)];
        [bezier2Path curveToPoint: NSMakePoint(109.01, 59.62) controlPoint1: NSMakePoint(108.83, 59.58) controlPoint2: NSMakePoint(108.32, 59.67)];
        [bezier2Path curveToPoint: NSMakePoint(109.65, 47.18) controlPoint1: NSMakePoint(109.87, 55.55) controlPoint2: NSMakePoint(109.95, 51.31)];
        [bezier2Path curveToPoint: NSMakePoint(100.22, 20.4) controlPoint1: NSMakePoint(108.96, 37.61) controlPoint2: NSMakePoint(106.16, 28.14)];
        [bezier2Path curveToPoint: NSMakePoint(75.62, 3.15) controlPoint1: NSMakePoint(93.96, 12.24) controlPoint2: NSMakePoint(85.16, 6.56)];
        [bezier2Path curveToPoint: NSMakePoint(60.26, 0) controlPoint1: NSMakePoint(70.77, 1.41) controlPoint2: NSMakePoint(65.44, 0.07)];
        [bezier2Path curveToPoint: NSMakePoint(14.64, 15.06) controlPoint1: NSMakePoint(39.87, 0) controlPoint2: NSMakePoint(26.7, 2.9)];
        [bezier2Path curveToPoint: NSMakePoint(2.04, 35.81) controlPoint1: NSMakePoint(8.89, 20.83) controlPoint2: NSMakePoint(4.4, 27.94)];
        [bezier2Path curveToPoint: NSMakePoint(0.51, 58.75) controlPoint1: NSMakePoint(-0.19, 43.19) controlPoint2: NSMakePoint(-0.41, 51.13)];
        [bezier2Path lineToPoint: NSMakePoint(0.52, 58.75)];
        [bezier2Path curveToPoint: NSMakePoint(3.61, 58.76) controlPoint1: NSMakePoint(1.51, 58.68) controlPoint2: NSMakePoint(2.51, 58.68)];
        [bezier2Path curveToPoint: NSMakePoint(3.77, 58.78) controlPoint1: NSMakePoint(3.66, 58.76) controlPoint2: NSMakePoint(3.72, 58.76)];
        [bezier2Path curveToPoint: NSMakePoint(4.11, 59.01) controlPoint1: NSMakePoint(4.04, 58.92) controlPoint2: NSMakePoint(3.94, 58.84)];
        [bezier2Path curveToPoint: NSMakePoint(4.93, 59.04) controlPoint1: NSMakePoint(4.72, 59.03) controlPoint2: NSMakePoint(4.44, 59.02)];
        [bezier2Path curveToPoint: NSMakePoint(5.51, 59.07) controlPoint1: NSMakePoint(5.44, 59.06) controlPoint2: NSMakePoint(5.25, 59.05)];
        [bezier2Path curveToPoint: NSMakePoint(6.07, 58.82) controlPoint1: NSMakePoint(5.64, 58.88) controlPoint2: NSMakePoint(5.86, 58.84)];
        [bezier2Path curveToPoint: NSMakePoint(10.5, 58.98) controlPoint1: NSMakePoint(7.55, 58.82) controlPoint2: NSMakePoint(9.03, 58.9)];
        [bezier2Path curveToPoint: NSMakePoint(12.78, 59.08) controlPoint1: NSMakePoint(11.92, 59.09) controlPoint2: NSMakePoint(11.16, 59.05)];
        [bezier2Path curveToPoint: NSMakePoint(13.4, 58.85) controlPoint1: NSMakePoint(12.94, 58.9) controlPoint2: NSMakePoint(13.17, 58.86)];
        [bezier2Path curveToPoint: NSMakePoint(17.08, 58.95) controlPoint1: NSMakePoint(14.44, 58.93) controlPoint2: NSMakePoint(15.47, 58.95)];
        [bezier2Path curveToPoint: NSMakePoint(17.72, 58.95) controlPoint1: NSMakePoint(17.25, 58.95) controlPoint2: NSMakePoint(17.4, 58.95)];
        [bezier2Path curveToPoint: NSMakePoint(19.54, 58.93) controlPoint1: NSMakePoint(18.34, 58.99) controlPoint2: NSMakePoint(18.93, 58.8)];
        [bezier2Path curveToPoint: NSMakePoint(20.34, 58.91) controlPoint1: NSMakePoint(20.03, 58.92) controlPoint2: NSMakePoint(19.76, 58.92)];
        [bezier2Path curveToPoint: NSMakePoint(20.81, 59.08) controlPoint1: NSMakePoint(20.66, 58.96) controlPoint2: NSMakePoint(20.5, 58.91)];
        [bezier2Path curveToPoint: NSMakePoint(32.55, 58.97) controlPoint1: NSMakePoint(24.73, 58.97) controlPoint2: NSMakePoint(28.64, 58.97)];
        [bezier2Path curveToPoint: NSMakePoint(34.98, 58.97) controlPoint1: NSMakePoint(33.23, 58.97) controlPoint2: NSMakePoint(33.77, 58.97)];
        [bezier2Path curveToPoint: NSMakePoint(38.71, 58.98) controlPoint1: NSMakePoint(36.85, 58.98) controlPoint2: NSMakePoint(37.68, 58.98)];
        [bezier2Path curveToPoint: NSMakePoint(39.25, 59.23) controlPoint1: NSMakePoint(38.94, 58.97) controlPoint2: NSMakePoint(39.1, 59.07)];
        [bezier2Path curveToPoint: NSMakePoint(40.68, 59.19) controlPoint1: NSMakePoint(39.73, 59.22) controlPoint2: NSMakePoint(40.2, 59.2)];
        [bezier2Path curveToPoint: NSMakePoint(45.4, 59.05) controlPoint1: NSMakePoint(42.25, 59.14) controlPoint2: NSMakePoint(43.83, 59.09)];
        [bezier2Path curveToPoint: NSMakePoint(52.74, 58.94) controlPoint1: NSMakePoint(48.19, 58.98) controlPoint2: NSMakePoint(50.5, 58.94)];
        [bezier2Path curveToPoint: NSMakePoint(53.28, 59.17) controlPoint1: NSMakePoint(52.95, 58.94) controlPoint2: NSMakePoint(53.13, 59.03)];
        [bezier2Path curveToPoint: NSMakePoint(59.38, 59.31) controlPoint1: NSMakePoint(57.08, 59.2) controlPoint2: NSMakePoint(55.05, 59.16)];
        [bezier2Path curveToPoint: NSMakePoint(60.14, 58.78) controlPoint1: NSMakePoint(59.5, 58.96) controlPoint2: NSMakePoint(59.8, 58.81)];
        [bezier2Path curveToPoint: NSMakePoint(62.82, 58.84) controlPoint1: NSMakePoint(60.88, 58.79) controlPoint2: NSMakePoint(61.48, 58.8)];
        [bezier2Path curveToPoint: NSMakePoint(63.35, 58.86) controlPoint1: NSMakePoint(63.08, 58.85) controlPoint2: NSMakePoint(63.2, 58.85)];
        [bezier2Path curveToPoint: NSMakePoint(66.32, 58.91) controlPoint1: NSMakePoint(64.63, 58.9) controlPoint2: NSMakePoint(65.46, 58.91)];
        [bezier2Path curveToPoint: NSMakePoint(67.11, 58.91) controlPoint1: NSMakePoint(66.54, 58.91) controlPoint2: NSMakePoint(66.71, 58.91)];
        [bezier2Path curveToPoint: NSMakePoint(67.65, 58.9) controlPoint1: NSMakePoint(67.38, 58.9) controlPoint2: NSMakePoint(67.5, 58.9)];
        [bezier2Path curveToPoint: NSMakePoint(69.45, 58.95) controlPoint1: NSMakePoint(68.38, 58.9) controlPoint2: NSMakePoint(68.92, 58.91)];
        [bezier2Path curveToPoint: NSMakePoint(70.14, 58.98) controlPoint1: NSMakePoint(69.66, 58.96) controlPoint2: NSMakePoint(69.88, 58.97)];
        [bezier2Path curveToPoint: NSMakePoint(70.63, 59) controlPoint1: NSMakePoint(70.28, 58.99) controlPoint2: NSMakePoint(70.39, 58.99)];
        [bezier2Path curveToPoint: NSMakePoint(70.85, 59.01) controlPoint1: NSMakePoint(70.74, 59.01) controlPoint2: NSMakePoint(70.79, 59.01)];
        [bezier2Path curveToPoint: NSMakePoint(71.34, 59.04) controlPoint1: NSMakePoint(70.96, 59.01) controlPoint2: NSMakePoint(71.11, 59.02)];
        [bezier2Path curveToPoint: NSMakePoint(71.39, 59.05) controlPoint1: NSMakePoint(71.36, 59.04) controlPoint2: NSMakePoint(71.36, 59.04)];
        [bezier2Path curveToPoint: NSMakePoint(71.6, 59.06) controlPoint1: NSMakePoint(71.38, 59.05) controlPoint2: NSMakePoint(71.56, 59.06)];
        [bezier2Path curveToPoint: NSMakePoint(71.68, 59.07) controlPoint1: NSMakePoint(71.62, 59.07) controlPoint2: NSMakePoint(71.65, 59.07)];
        [bezier2Path curveToPoint: NSMakePoint(71.69, 59.07) controlPoint1: NSMakePoint(71.68, 59.07) controlPoint2: NSMakePoint(71.68, 59.07)];
        [bezier2Path curveToPoint: NSMakePoint(72.06, 59.09) controlPoint1: NSMakePoint(71.81, 59.07) controlPoint2: NSMakePoint(71.93, 59.09)];
        [bezier2Path curveToPoint: NSMakePoint(72.3, 59.11) controlPoint1: NSMakePoint(72.18, 59.1) controlPoint2: NSMakePoint(72.23, 59.1)];
        [bezier2Path curveToPoint: NSMakePoint(72.41, 59.1) controlPoint1: NSMakePoint(72.29, 59.11) controlPoint2: NSMakePoint(72.33, 59.1)];
        [bezier2Path curveToPoint: NSMakePoint(72.75, 59.09) controlPoint1: NSMakePoint(72.58, 59.08) controlPoint2: NSMakePoint(72.65, 59.08)];
        [bezier2Path curveToPoint: NSMakePoint(72.93, 59.12) controlPoint1: NSMakePoint(72.81, 59.09) controlPoint2: NSMakePoint(72.87, 59.1)];
        [bezier2Path curveToPoint: NSMakePoint(73.33, 59.28) controlPoint1: NSMakePoint(73.08, 59.15) controlPoint2: NSMakePoint(73.18, 59.26)];
        [bezier2Path curveToPoint: NSMakePoint(74.19, 59.37) controlPoint1: NSMakePoint(73.85, 59.33) controlPoint2: NSMakePoint(73.57, 59.31)];
        [bezier2Path curveToPoint: NSMakePoint(74.79, 59.1) controlPoint1: NSMakePoint(74.34, 59.17) controlPoint2: NSMakePoint(74.56, 59.12)];
        [bezier2Path curveToPoint: NSMakePoint(75.71, 59.11) controlPoint1: NSMakePoint(75.09, 59.1) controlPoint2: NSMakePoint(75.4, 59.11)];
        [bezier2Path lineToPoint: NSMakePoint(76.04, 59.11)];
        [bezier2Path curveToPoint: NSMakePoint(76.67, 59.11) controlPoint1: NSMakePoint(76.5, 59.11) controlPoint2: NSMakePoint(76.29, 59.11)];
        [bezier2Path curveToPoint: NSMakePoint(80.91, 59.01) controlPoint1: NSMakePoint(78.08, 59.09) controlPoint2: NSMakePoint(79.5, 59.06)];
        [bezier2Path curveToPoint: NSMakePoint(82.94, 58.96) controlPoint1: NSMakePoint(81.93, 58.98) controlPoint2: NSMakePoint(82.38, 58.97)];
        [bezier2Path curveToPoint: NSMakePoint(89.12, 59) controlPoint1: NSMakePoint(85, 58.89) controlPoint2: NSMakePoint(87.06, 58.91)];
        [bezier2Path curveToPoint: NSMakePoint(89.61, 58.88) controlPoint1: NSMakePoint(89.27, 58.88) controlPoint2: NSMakePoint(89.44, 58.88)];
        [bezier2Path curveToPoint: NSMakePoint(92.12, 59.06) controlPoint1: NSMakePoint(90.99, 58.99) controlPoint2: NSMakePoint(90.15, 58.93)];
        [bezier2Path lineToPoint: NSMakePoint(92.26, 59.06)];
        [bezier2Path curveToPoint: NSMakePoint(92.95, 58.68) controlPoint1: NSMakePoint(92.43, 58.8) controlPoint2: NSMakePoint(92.65, 58.7)];
        [bezier2Path curveToPoint: NSMakePoint(98.3, 58.83) controlPoint1: NSMakePoint(94.73, 58.71) controlPoint2: NSMakePoint(96.52, 58.77)];
        [bezier2Path curveToPoint: NSMakePoint(99.16, 58.86) controlPoint1: NSMakePoint(98.73, 58.85) controlPoint2: NSMakePoint(98.92, 58.85)];
        [bezier2Path curveToPoint: NSMakePoint(106.23, 59.01) controlPoint1: NSMakePoint(101.51, 58.94) controlPoint2: NSMakePoint(103.87, 59.01)];
        [bezier2Path curveToPoint: NSMakePoint(107.03, 59.67) controlPoint1: NSMakePoint(106.67, 59.02) controlPoint2: NSMakePoint(106.87, 59.3)];
        [bezier2Path lineToPoint: NSMakePoint(107.04, 59.81)];
        [bezier2Path closePath];
        [bezier2Path setMiterLimit: 4];
        [computedWaterColor setFill];
        [bezier2Path fill];


        //// Bezier 3 Drawing
        NSBezierPath* bezier3Path = NSBezierPath.bezierPath;
        [bezier3Path moveToPoint: NSMakePoint(8.18, 62.42)];
        [bezier3Path curveToPoint: NSMakePoint(8.3, 61.87) controlPoint1: NSMakePoint(8.2, 62.19) controlPoint2: NSMakePoint(8.19, 62.13)];
        [bezier3Path curveToPoint: NSMakePoint(9.62, 60.54) controlPoint1: NSMakePoint(8.54, 61.29) controlPoint2: NSMakePoint(9.09, 60.84)];
        [bezier3Path curveToPoint: NSMakePoint(11.79, 59.62) controlPoint1: NSMakePoint(10.35, 60.12) controlPoint2: NSMakePoint(10.95, 59.87)];
        [bezier3Path curveToPoint: NSMakePoint(16.17, 58.87) controlPoint1: NSMakePoint(13.21, 59.17) controlPoint2: NSMakePoint(14.69, 59)];
        [bezier3Path curveToPoint: NSMakePoint(22.67, 60.54) controlPoint1: NSMakePoint(18.37, 59.07) controlPoint2: NSMakePoint(20.74, 59.37)];
        [bezier3Path curveToPoint: NSMakePoint(24.11, 62.42) controlPoint1: NSMakePoint(23.38, 60.96) controlPoint2: NSMakePoint(24.05, 61.55)];
        [bezier3Path curveToPoint: NSMakePoint(26.68, 59.98) controlPoint1: NSMakePoint(24.21, 61.12) controlPoint2: NSMakePoint(25.62, 60.41)];
        [bezier3Path curveToPoint: NSMakePoint(32.67, 58.83) controlPoint1: NSMakePoint(28.59, 59.21) controlPoint2: NSMakePoint(30.64, 58.96)];
        [bezier3Path curveToPoint: NSMakePoint(39.27, 60.25) controlPoint1: NSMakePoint(34.91, 58.97) controlPoint2: NSMakePoint(37.23, 59.25)];
        [bezier3Path curveToPoint: NSMakePoint(41.24, 62.42) controlPoint1: NSMakePoint(40.15, 60.68) controlPoint2: NSMakePoint(41.16, 61.34)];
        [bezier3Path curveToPoint: NSMakePoint(43.81, 59.98) controlPoint1: NSMakePoint(41.34, 61.12) controlPoint2: NSMakePoint(42.75, 60.41)];
        [bezier3Path curveToPoint: NSMakePoint(49.26, 58.86) controlPoint1: NSMakePoint(45.54, 59.28) controlPoint2: NSMakePoint(47.42, 58.98)];
        [bezier3Path curveToPoint: NSMakePoint(55.85, 60.54) controlPoint1: NSMakePoint(51.49, 59.06) controlPoint2: NSMakePoint(53.89, 59.35)];
        [bezier3Path curveToPoint: NSMakePoint(57.28, 62.42) controlPoint1: NSMakePoint(56.55, 60.96) controlPoint2: NSMakePoint(57.22, 61.55)];
        [bezier3Path curveToPoint: NSMakePoint(59.86, 59.98) controlPoint1: NSMakePoint(57.38, 61.12) controlPoint2: NSMakePoint(58.79, 60.41)];
        [bezier3Path curveToPoint: NSMakePoint(65.52, 58.85) controlPoint1: NSMakePoint(61.66, 59.25) controlPoint2: NSMakePoint(63.6, 58.97)];
        [bezier3Path curveToPoint: NSMakePoint(72.33, 60.54) controlPoint1: NSMakePoint(67.82, 59.04) controlPoint2: NSMakePoint(70.31, 59.31)];
        [bezier3Path curveToPoint: NSMakePoint(73.76, 62.42) controlPoint1: NSMakePoint(73.03, 60.96) controlPoint2: NSMakePoint(73.7, 61.55)];
        [bezier3Path curveToPoint: NSMakePoint(76.34, 59.98) controlPoint1: NSMakePoint(73.86, 61.12) controlPoint2: NSMakePoint(75.27, 60.41)];
        [bezier3Path curveToPoint: NSMakePoint(82.35, 58.82) controlPoint1: NSMakePoint(78.25, 59.2) controlPoint2: NSMakePoint(80.31, 58.96)];
        [bezier3Path curveToPoint: NSMakePoint(88.97, 60.25) controlPoint1: NSMakePoint(84.59, 58.97) controlPoint2: NSMakePoint(86.92, 59.24)];
        [bezier3Path curveToPoint: NSMakePoint(90.94, 62.42) controlPoint1: NSMakePoint(89.85, 60.68) controlPoint2: NSMakePoint(90.86, 61.34)];
        [bezier3Path curveToPoint: NSMakePoint(93.51, 59.98) controlPoint1: NSMakePoint(91.04, 61.12) controlPoint2: NSMakePoint(92.44, 60.41)];
        [bezier3Path curveToPoint: NSMakePoint(99.74, 58.81) controlPoint1: NSMakePoint(95.5, 59.18) controlPoint2: NSMakePoint(97.63, 58.95)];
        [bezier3Path curveToPoint: NSMakePoint(106.39, 60.11) controlPoint1: NSMakePoint(102.02, 58.87) controlPoint2: NSMakePoint(104.27, 59.26)];
        [bezier3Path curveToPoint: NSMakePoint(108.34, 61.51) controlPoint1: NSMakePoint(107.08, 60.4) controlPoint2: NSMakePoint(107.89, 60.88)];
        [bezier3Path curveToPoint: NSMakePoint(108.53, 61.87) controlPoint1: NSMakePoint(108.41, 61.63) controlPoint2: NSMakePoint(108.47, 61.75)];
        [bezier3Path lineToPoint: NSMakePoint(108.59, 62.07)];
        [bezier3Path curveToPoint: NSMakePoint(108.94, 60.72) controlPoint1: NSMakePoint(108.7, 61.62) controlPoint2: NSMakePoint(108.82, 61.17)];
        [bezier3Path curveToPoint: NSMakePoint(109.15, 59.93) controlPoint1: NSMakePoint(109.05, 60.31) controlPoint2: NSMakePoint(109.09, 60.15)];
        [bezier3Path curveToPoint: NSMakePoint(109.42, 58.79) controlPoint1: NSMakePoint(109.26, 59.5) controlPoint2: NSMakePoint(109.34, 59.14)];
        [bezier3Path lineToPoint: NSMakePoint(109.42, 58.79)];
        [bezier3Path lineToPoint: NSMakePoint(100.85, 58.79)];
        [bezier3Path lineToPoint: NSMakePoint(100.85, 58.79)];
        [bezier3Path lineToPoint: NSMakePoint(14.2, 58.79)];
        [bezier3Path lineToPoint: NSMakePoint(14.2, 58.79)];
        [bezier3Path lineToPoint: NSMakePoint(0.45, 58.79)];
        [bezier3Path lineToPoint: NSMakePoint(0.45, 58.8)];
        [bezier3Path curveToPoint: NSMakePoint(0.45, 58.86) controlPoint1: NSMakePoint(0.46, 58.82) controlPoint2: NSMakePoint(0.45, 58.84)];
        [bezier3Path lineToPoint: NSMakePoint(0.46, 58.89)];
        [bezier3Path curveToPoint: NSMakePoint(2.92, 59.21) controlPoint1: NSMakePoint(1.52, 58.98) controlPoint2: NSMakePoint(1.48, 58.96)];
        [bezier3Path curveToPoint: NSMakePoint(3.79, 59.4) controlPoint1: NSMakePoint(3.21, 59.26) controlPoint2: NSMakePoint(3.5, 59.34)];
        [bezier3Path curveToPoint: NSMakePoint(5.22, 59.84) controlPoint1: NSMakePoint(4.28, 59.52) controlPoint2: NSMakePoint(4.75, 59.68)];
        [bezier3Path curveToPoint: NSMakePoint(5.92, 60.11) controlPoint1: NSMakePoint(5.46, 59.92) controlPoint2: NSMakePoint(5.69, 60.02)];
        [bezier3Path curveToPoint: NSMakePoint(8.07, 61.87) controlPoint1: NSMakePoint(6.7, 60.44) controlPoint2: NSMakePoint(7.72, 61.04)];
        [bezier3Path curveToPoint: NSMakePoint(8.17, 62.24) controlPoint1: NSMakePoint(8.12, 61.99) controlPoint2: NSMakePoint(8.14, 62.12)];
        [bezier3Path lineToPoint: NSMakePoint(8.18, 62.42)];
        [bezier3Path closePath];
        [bezier3Path setMiterLimit: 4];
        [computedWaveColor setFill];
        [bezier3Path fill];



        [NSGraphicsContext restoreGraphicsState];
    }
}

#pragma mark Generated Images

+ (NSImage*)imageOfIconWithIsConnected: (BOOL)isConnected isSyncInProgress: (BOOL)isSyncInProgress;
{
    return [NSImage imageWithSize: NSMakeSize(16, 16) flipped: NO drawingHandler: ^(NSRect dstRect)
    {
        [GlukloaderIcon drawIconWithIsConnected: isConnected isSyncInProgress: isSyncInProgress];
        return YES;
    }];
}

@end
