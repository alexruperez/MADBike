//
//  BMEMTIncidencesTask.m
//  BiciMAD
//
//  Created by Alex Rupérez on 10/06/17.
//  Copyright © 2017 alexruperez. All rights reserved.
//

#import "BMEMTIncidencesTask.h"

#import "BMServiceTaskProtocol.h"
#import "BMStation.h"
#import "BMAnalyticsManager.h"

@interface BMEMTIncidencesTask () <BMServiceTask>

@end

@implementation BMEMTIncidencesTask

- (NSString *)requestURLString
{
    return kBMRequestIncidencesEMTURLString;
}

- (NSString *)HTTPMethod
{
    return kBMHTTPClientPOSTMethod;
}

- (NSObject *)JSONBody
{
    return @{ @"idClient": BMAnalyticsManager.keys.eMTClientId,
              @"passKey": BMAnalyticsManager.keys.eMTPassKey,
              @"preferredChannel": self.phonePreferred ? @"TELEFONO" : @"EMAIL",
              @"phone": self.phone,
              @"email": self.email,
              @"lastName": self.lastName,
              @"subject": self.subject,
              @"texto": self.text
              };
}

- (id)parseResponseObject:(NSDictionary *)responseObject error:(NSError **)error
{
    return responseObject[kBMEMTDescriptionKey];
}

@end
