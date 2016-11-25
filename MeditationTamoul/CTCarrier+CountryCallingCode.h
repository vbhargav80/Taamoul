//
//  CTCarrier+CountryCallingCode.h
//  Xhoppe
//
//  Created by Cheng Yao on 23/11/14.
//  Copyright (c) 2014 Cheng Yao. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface CTCarrier (CountryCallingCode)

- (NSString *)countryCallingCode;
+ (NSDictionary *)callingCodeMap;

@end