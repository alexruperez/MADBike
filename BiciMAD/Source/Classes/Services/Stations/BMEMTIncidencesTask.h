//
//  BMEMTIncidencesTask.h
//  BiciMAD
//
//  Created by Alex Rupérez on 10/06/17.
//  Copyright © 2017 alexruperez. All rights reserved.
//

#import "BMEMTServiceTask.h"

@interface BMEMTIncidencesTask : BMEMTServiceTask

@property (nonatomic, assign) BOOL phonePreferred;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *text;

@end
