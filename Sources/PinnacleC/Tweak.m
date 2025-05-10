#import <Orion/Orion.h>
#import <libroot.h>

__attribute__((constructor)) static void init() {
  // Initialize Orion - do not remove this line.
  orion_init();
  // Custom initialization code goes here.
}

NSString *plusCirclePath() {
  return JBROOT_PATH_NSSTRING(
      @"/Library/Tweak Support/dev.rugmj.pinnacle/plus-circle.png");
}

NSString *grabberPath() {
  return JBROOT_PATH_NSSTRING(
      @"/Library/Tweak Support/dev.rugmj.pinnacle/grabber.png");
}
