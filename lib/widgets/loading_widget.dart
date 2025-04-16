import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoadingWidget extends StatelessWidget {
  bool inAsyncCall;
  Widget child;

  LoadingWidget({Key? key, this.inAsyncCall = true, this.child = const SizedBox()})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: inAsyncCall,
      color: kPinkColor,
      opacity: 0.1,
      progressIndicator: LoadingAnimationWidget.staggeredDotsWave(color: kPurpleColor, size: 50),
      child: child,
    );
  }
}
