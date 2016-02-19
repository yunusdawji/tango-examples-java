/*
 
 File: TransferService.h
 
 Abstract: The UUIDs generated to identify the Service and Characteristics
 used in the App.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */


#ifndef LE_Transfer_TransferService_h
#define LE_Transfer_TransferService_h

//uuid to broadcast for transaction
#define TRANSFER_SERVICE_UUID           @"69646579-6553-2070-6553-00A33AF96741"
#define SERVICE_UUID                    @"B66AB861-0000-40BE-E311-00A33AF96741"
#define ORDERNO_CHARACTERISTIC_UUID     @"B66AB861-0000-40BE-E311-01A33AF96741"
#define CONFIRMKEY_CHARACTERISTIC_UUID  @"B66AB861-0000-40BE-E311-02A33AF96741"
#define PAYKEY_CHARACTERISTIC_UUID      @"B66AB861-0000-40BE-E311-03A33AF96741"
#define TRANSFER_CHARACTERISTICNF_UUID  @"B66AB861-0000-40BE-E311-04A33AF96741"
#define TRANSFER_CHARACTERISTIC_UUID    @"B66AB861-0000-40BE-E311-05A33AF96741"
#define LOYALTY_CHARACTERISTIC_UUID     @"B66AB861-0000-40BE-E311-06A33AF96741"
#define STATUS_CHARACTERISTIC_UUID      @"B66AB861-0000-40BE-E311-07A33AF96741"
#define KEY_CHARACTERISTIC_UUID         @"B66AB861-0000-40BE-E311-08A33AF96741"
#define CERTIFICATE_CHARACTERISTIC_UUID @"B66AB861-0000-40BE-E311-09A33AF96741"

////////////////////////////////////////////////////////////////////////////////////////////
//*#define SUBMIT_ORDER_URL              @"http://192.168.1.104/pos/submitorder.php"      //
//#define VERIFY_URL                      @"http://192.168.1.104/pos/verifyconfirmkey.php"//
//#define CONFIRM_PAYMENT                 @"http://192.168.1.104/pos/confirmpayment.php"] //
//*/                                                                                      //
////////////////////////////////////////////////////////////////////////////////////////////

#define SUBMIT_ORDER_URL                @"/pos/submitorder.php"
#define VERIFY_URL                      @"/pos/verifyconfirmkey.php"
#define CONFIRM_PAYMENT                 @"/pos/confirmpayment.php"

#define kSUBMIT_ORDER_URL                @"SUBMIT_ORDER_URL"
#define kVERIFY_URL                      @"VERIFY_URL"
#define kCONFIRM_PAYMENT                 @"CONFIRM_PAYMENT"

//this is http error domain used by the delegate
#define kHTTPERRORDOMAIN                 @"com.innovationlab.hyphen.connectionerror"

//this is domain for confirm key match failed
#define kCONFIRMKEYMATCHFAILEDERRORDOMAIN @"com.innovationlab.hyphen.confirmkeymatchfailed"

//this is domain for pay key update failed error
#define kPAYKEYUPDATEFAILEDERRORDOMAIN  @"com.innovationlab.hyphen.paykeyupdatefailed"

//details of confirm key match failed error
#define kCONFIRMKEYMATCHFAILEDERRORSTRING @"Error verifying confirmation key"

//details of paykey update failed error
#define kPAYKEYUPDATEFAILEDERRORSTRING  @"Error updating paykey"

//code to be written if confirmkey is matched
#define CONFIRMKEYMATCHEDCODE           @"k:s1"

//code to be written if confirmkey match failed
#define CONFIRMKEYFAILEDCODE            @"k:f1"

#endif