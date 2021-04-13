#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(CombateAFraude, RCTEventEmitter)

RCT_EXTERN_METHOD(passiveFaceLiveness:(NSString *)mobileToken)

@end
