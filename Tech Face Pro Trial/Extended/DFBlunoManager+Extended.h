//
//  DFBlunoManager+Extended.h
//  Tech Face
//
//  Created by John on 2019-6-19.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "DFBlunoManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DFBlunoManager (Extended)

/**
 [""] *	@brief	Write the data to the device
 [""] *
 [""] *	@param 	data 	NSData
 [""] *	@param 	dev 	DFBlunoDevice
 [""] *
 [""] *	@return	void
 [""] */
- (void)writeData:(NSData *)data toDevice:(DFBlunoDevice *)device;


/**
 [""] *	@brief	Write the string to the device
 [""] *
 [""] *	@param 	string 	NSString
 [""] *	@param 	dev 	DFBlunoDevice
 [""] *
 [""] *	@return	void
 [""] */
- (void)writeString:(NSString *)string toDevice:(DFBlunoDevice *)device;

@end

NS_ASSUME_NONNULL_END
