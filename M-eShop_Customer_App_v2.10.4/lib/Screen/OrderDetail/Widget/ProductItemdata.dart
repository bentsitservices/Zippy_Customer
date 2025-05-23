import 'dart:io';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/cubits/predefinesReturnReasonCubit.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/UpdateOrderProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import 'BottomSheetWidget.dart';
import 'OrderStatusData.dart';

class ProductItemWidget extends StatefulWidget {
  OrderItem orderItem;
  OrderModel model;
  String id;
  Function updateNow;

  ProductItemWidget({
    Key? key,
    required this.id,
    required this.model,
    required this.orderItem,
    required this.updateNow,
  }) : super(key: key);

  @override
  State<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  String filePath = '';
  int _selectedValue = 0;
  bool _isOtherSelected = false;
  final ScrollController predefinedReasonScrollController = ScrollController();
  List<String> statusList = [
    'awaiting',
    'received',
    'processed',
    'shipped',
    'delivered',
    'cancelled',
    'return_pickedup',
    'returned'
  ];

  setSanckBarNow(String msg) {
    setSnackbar(msg, context);
    context.read<UpdateOrdProvider>().reviewPhotos.clear();
    context.read<UpdateOrdProvider>().imageVideoFiles.clear();
    context.read<UpdateOrdProvider>().changeStatus(UpdateOrdStatus.isSuccsess);
  }

  @override
  void initState() {
    context
        .read<PredefinedReturnReasonListCubit>()
        .getPredefinedReturnReasonList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? pDate,
        prDate,
        sDate,
        dDate,
        cDate,
        rDate,
        aDate,
        repDate,
        reapDate,
        returnPickupDate,
        redDate;

    if (widget.orderItem.listStatus!.contains(WAITING)) {
      aDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(WAITING)];
    }
    if (widget.orderItem.listStatus!.contains(PLACED)) {
      pDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(PLACED)];
    }
    if (widget.orderItem.listStatus!.contains(PROCESSED)) {
      prDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(PROCESSED)];
    }
    if (widget.orderItem.listStatus!.contains(SHIPED)) {
      sDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(SHIPED)];
    }
    if (widget.orderItem.listStatus!.contains(DELIVERD)) {
      dDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(DELIVERD)];
    }
    if (widget.orderItem.listStatus!.contains(CANCLED)) {
      cDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(CANCLED)];
    }
    if (widget.orderItem.listStatus!.contains(RETURNED)) {
      rDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(RETURNED)];
    }
    if (widget.orderItem.listStatus!.contains(PICKUP_ACCEPT)) {
      returnPickupDate = widget.orderItem
          .listDate![widget.orderItem.listStatus!.indexOf(PICKUP_ACCEPT)];
    }
    if (widget.orderItem.listStatus!.contains(RETURN_REQ_PENDING)) {
      repDate = widget.orderItem
          .listDate![widget.orderItem.listStatus!.indexOf(RETURN_REQ_PENDING)];
    }
    if (widget.orderItem.listStatus!.contains(RETURN_REQ_APPROVED)) {
      reapDate = widget.orderItem
          .listDate![widget.orderItem.listStatus!.indexOf(RETURN_REQ_APPROVED)];
    }
    if (widget.orderItem.listStatus!.contains(RETURN_REQ_DECLINE)) {
      redDate = widget.orderItem
          .listDate![widget.orderItem.listStatus!.indexOf(RETURN_REQ_DECLINE)];
    }
    List att = [], val = [];
    if (widget.orderItem.attr_name!.isNotEmpty) {
      att = widget.orderItem.attr_name!.split(',');
      val = widget.orderItem.varient_values!.split(',');
    }

    int caclabelTillIndex = statusList
        .indexWhere((element) => element == widget.orderItem.canclableTill);

    int curStatusIndex =
        statusList.indexWhere((element) => element == widget.orderItem.status);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(circularBorderRadius7),
                  child: DesignConfiguration.getCacheNotworkImage(
                    boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                    context: context,
                    heightvalue: 90.0,
                    widthvalue: 90.0,
                    imageurlString: widget.orderItem.image!,
                    placeHolderSize: 90,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.orderItem.name!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.normal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        widget.orderItem.attr_name!.isNotEmpty
                            ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: att.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          att[index].trim() + ':',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack2),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 5.0),
                                        child: Text(
                                          val[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                              ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              )
                            : const SizedBox(),
                        Row(
                          children: [
                            Text(
                              '${getTranslated(context, 'QUANTITY_LBL')}: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 5.0),
                              child: Text(
                                widget.orderItem.qty!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                              ),
                            )
                          ],
                        ),
                        Text(
                          DesignConfiguration.getPriceFormat(
                              context, double.parse(widget.orderItem.price!))!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.blue),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  pDate != null
                      ? getPlaced(pDate, context)
                      // : getPlaced(aDate ?? '', context),
                      : getPlaced('', context),
                  widget.orderItem.productType == 'digital_product'
                      ? const SizedBox()
                      : getProcessed(prDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? const SizedBox()
                      : getShipped(sDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? const SizedBox()
                      : getDelivered(dDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? widget.orderItem.downloadAllowed == '1'
                          ? cDate == null
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: VerticalDivider(
                                            thickness: 2,
                                            color: dDate == null
                                                ? Colors.grey
                                                : colors.primary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: dDate == null
                                              ? Colors.grey
                                              : colors.primary,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'ORDER_DELIVERED'),
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            dDate ?? ' ',
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox()
                          : const SizedBox()
                      : const SizedBox(),
                  widget.orderItem.productType == 'digital_product'
                      ? widget.orderItem.downloadAllowed != '1'
                          ? cDate == null
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: VerticalDivider(
                                            thickness: 2,
                                            color: dDate == null
                                                ? Colors.grey
                                                : colors.primary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: dDate == null
                                              ? Colors.grey
                                              : colors.primary,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'ORDER_DELIVERED'),
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            dDate ?? ' ',
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            getTranslated(context,
                                                'PLEASE_CHECK_YOUR_MAIL_FOR_INSTRUCTIONS'),
                                            style: TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox()
                          : const SizedBox()
                      : const SizedBox(),
                  getCanceled(cDate, context),
                  getReturneRequestPending(
                      widget.orderItem, repDate, widget.model, context),
                  getReturneRequestApproved(
                      widget.orderItem, reapDate, widget.model, context),
                  getReturneRequestDecline(
                      widget.orderItem, redDate, widget.model, context),
                  getPickupAccept(widget.orderItem, returnPickupDate,
                      widget.model, context),
                  getReturned(widget.orderItem, rDate, widget.model, context),
                ],
              ),
            ),
            widget.orderItem.downloadAllowed == '1' &&
                    widget.orderItem.status == DELIVERD
                ? downloadProductFile(context, widget.orderItem.id!)
                : const SizedBox(),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslated(context, "STORE_NAME")} : ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      widget.orderItem.item_otp != '' &&
                              widget.orderItem.item_otp != null
                          ? Text(
                              "${getTranslated(context, "OTP")} : ",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.bold),
                            )
                          : SizedBox.shrink(),
                      widget.orderItem.courier_agency! != ''
                          ? Text(
                              "${getTranslated(context, 'COURIER_AGENCY')}: ",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                      widget.orderItem.tracking_id! != ''
                          ? Text(
                              "${getTranslated(context, 'TRACKING_ID')}: ",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Text(
                          '${widget.orderItem.store_name}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack2,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          print(widget.orderItem.seller_name);
                          print(widget.orderItem.seller_no_of_ratings);
                          Routes.navigateToSellerProfileScreen(
                            context,
                            widget.orderItem.seller_id,
                            widget.orderItem.seller_profile,
                            widget.orderItem.seller_name,
                            widget.orderItem.seller_rating,
                            widget.orderItem.seller_name,
                            widget.orderItem.store_description,
                            '0',
                            widget.orderItem.seller_no_of_ratings,
                          );
                        },
                      ),
                      widget.orderItem.item_otp != '' &&
                              widget.orderItem.item_otp != null
                          ? Text(
                              '${widget.orderItem.item_otp} ',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.lightBlack2,
                              ),
                            )
                          : SizedBox.shrink(),
                      widget.orderItem.courier_agency! != ''
                          ? Text(
                              widget.orderItem.courier_agency!,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.lightBlack2,
                              ),
                            )
                          : const SizedBox(),
                      widget.orderItem.tracking_id! != ''
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.orderItem.tracking_id!,
                                    style: const TextStyle(
                                        color: colors.primary,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        var url =
                                            '${widget.orderItem.tracking_url}';

                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        } else {
                                          setSnackbar(
                                              getTranslated(
                                                  context, 'URL_ERROR'),
                                              context);
                                        }
                                      },
                                  )
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.orderItem.status == DELIVERD)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        openBottomSheet(
                          context,
                          widget.orderItem,
                          setSanckBarNow,
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined,
                          color: colors.primary),
                      label: Text(
                        widget.orderItem.userReviewRating != '0'
                            ? getTranslated(context, 'UPDATE_REVIEW_LBL')
                            : getTranslated(context, 'WRITE_REVIEW_LBL'),
                        style: const TextStyle(color: colors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.btnColor),
                      ),
                    ),
                  ),
                if (!widget.orderItem.listStatus!.contains(DELIVERD) &&
                    (!widget.orderItem.listStatus!.contains(RETURNED)) &&
                    widget.orderItem.isCancle == '1' &&
                    widget.orderItem.isAlrCancelled == '0' &&
                    curStatusIndex <= caclabelTillIndex)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: context
                                .read<UpdateOrdProvider>()
                                .isReturnClick
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext cxt) {
                                    return AlertDialog(
                                      title: Text(
                                        getTranslated(cxt, 'ARE_YOU_SURE?'),
                                        style: TextStyle(
                                            color: Theme.of(cxt)
                                                .colorScheme
                                                .fontColor),
                                      ),
                                      content: Text(
                                        getTranslated(cxt,
                                            'Would you like to cancel this product?'),
                                        style: TextStyle(
                                          color: Theme.of(cxt)
                                              .colorScheme
                                              .fontColor,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            getTranslated(cxt, 'YES'),
                                            style: const TextStyle(
                                                color: colors.primary),
                                          ),
                                          onPressed: () {
                                            Routes.pop(cxt);

                                            cxt
                                                .read<UpdateOrdProvider>()
                                                .isReturnClick = false;
                                            cxt
                                                .read<UpdateOrdProvider>()
                                                .changeStatus(
                                                    UpdateOrdStatus.inProgress);
                                            /* setSnackbar(
                                                getTranslated(context,
                                                    'Status Updated Successfully')!,
                                                context);*/
                                            /*Future.delayed(Duration.zero).then(
                                              (value) => */
                                            cxt
                                                .read<UpdateOrdProvider>()
                                                .cancelOrder(
                                                  widget.orderItem.id!,
                                                  updateOrderItemApi,
                                                  CANCLED,
                                                );
                                            widget.updateNow();
                                            /*  ),
                                            );*/
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            getTranslated(cxt, 'NO'),
                                            style: const TextStyle(
                                                color: colors.primary),
                                          ),
                                          onPressed: () {
                                            Routes.pop(cxt);
                                            /* context
                                                .read<UpdateOrdProvider>()
                                                .changeStatus(UpdateOrdStatus.inProgress);*/
                                            setState(() {});
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            : null,
                        child: Text(
                          getTranslated(context, 'ITEM_CANCEL'),
                        ),
                      ),
                    ),
                  )
                else
                  ((widget.orderItem.listStatus!.contains(DELIVERD) &&
                              widget.orderItem.productType !=
                                  'digital_product') &&
                          widget.orderItem.isReturn == '1' &&
                          widget.orderItem.isAlrReturned == '0' &&
                          (!widget.orderItem.listStatus!
                                  .contains(RETURN_REQ_DECLINE) &&
                              !widget.orderItem.listStatus!
                                  .contains(RETURN_REQ_APPROVED) &&
                              !widget.orderItem.listStatus!
                                  .contains(RETURN_REQ_PENDING)))
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: OutlinedButton(
                            onPressed:
                                context.read<UpdateOrdProvider>().isReturnClick
                                    ? () {
                                        openItemReturnBottomSheet(
                                          context,
                                        );
                                      }
                                    : null,
                            child: Text(getTranslated(context, 'ITEM_RETURN')),
                          ),
                        )
                      : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openItemReturnBottomSheet(
    BuildContext parentContext,
  ) {
    context.read<UpdateOrdProvider>().otherReasonTextEditingController.clear();
    _selectedValue = 0;
    _isOtherSelected = false;
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(circularBorderRadius40),
          topRight: Radius.circular(
            circularBorderRadius40,
          ),
        ),
      ),
      isScrollControlled: true,
      context: parentContext,
      builder: (context) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  bottomSheetHandle(context),
                  selectReturnReasonLabel(),
                  selectReturnReason(),
                  getReturnReasonImageField(),
                  submitReturnReasonButton(parentContext),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget selectReturnReasonLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        getTranslated(context, 'SELECT_RETURN_REASON'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontFamily: 'ubuntu',
            color: Theme.of(context).colorScheme.fontColor),
      ),
    );
  }

  selectReturnReason() {
    return BlocBuilder<PredefinedReturnReasonListCubit,
        PredefinedReturnReasonListState>(
      builder: (context, state) {
        print("ReasonState---->${state}");
        if (state is PredefinedReturnReasonListSuccess) {
          if (_selectedValue == 0 &&
              context.read<UpdateOrdProvider>().selectedReason.isEmpty) {
            context.read<UpdateOrdProvider>().selectedReason =
                state.predefinedReason[0].returnReason;
          }
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    controller: predefinedReasonScrollController,
                    child: Column(
                      children: [
                        ...state.predefinedReason
                            .asMap()
                            .map(
                              (index, element) => MapEntry(
                                index,
                                RadioListTile<int>(
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width: 40, // Set appropriate size
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              circularBorderRadius5),
                                          child: DesignConfiguration
                                              .getCacheNotworkImage(
                                            boxFit: BoxFit.fill,
                                            context: context,
                                            heightvalue: 40,
                                            widthvalue: 40,
                                            imageurlString: state
                                                .predefinedReason[index].image,
                                            placeHolderSize: null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.predefinedReason[index]
                                              .returnReason,
                                          style: TextStyle(
                                            color: _selectedValue == index
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                            fontSize: textFontSize16,
                                            fontFamily: 'ubuntu',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: index,
                                  groupValue: _selectedValue,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  onChanged: (int? value) {
                                    setState(() {
                                      _selectedValue = value!;
                                      _isOtherSelected = false;
                                      context
                                              .read<UpdateOrdProvider>()
                                              .selectedReason =
                                          state.predefinedReason[index]
                                              .returnReason;
                                    });
                                  },
                                ),
                              ),
                            )
                            .values
                            .toList(),

                        // "Other" Option
                        RadioListTile<int>(
                          title: Text(
                            "Other",
                            style: TextStyle(
                              color: _isOtherSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                              fontSize: textFontSize16,
                              fontFamily: 'ubuntu',
                            ),
                          ),
                          value: state.predefinedReason.length,
                          groupValue: _selectedValue,
                          activeColor: Theme.of(context).colorScheme.primary,
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedValue = value!;
                              _isOtherSelected = true;
                              context.read<UpdateOrdProvider>().selectedReason =
                                  '';
                            });
                          },
                        ),

                        if (_isOtherSelected)
                          writeOtherReason(context, setState),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget getReturnReasonImageField() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          padding:
              const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 5),
          height: 120,
          child: Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          _returnReasonImgFromGallery(setModalState, context);
                        },
                      ),
                    ),
                    Text(
                      getTranslated(context, 'ADD_YOUR_PHOTOS'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontSize: textFontSize11,
                        fontFamily: 'ubuntu',
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      context.read<UpdateOrdProvider>().imageVideoFiles.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    File file =
                        context.read<UpdateOrdProvider>().imageVideoFiles[i];
                    String extension = file.path.split('.').last.toLowerCase();

                    return Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: extension == 'jpg' ||
                                    extension == 'jpeg' ||
                                    extension == 'png'
                                ? Image.file(
                                    file,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: colors.blackTemp
                                            .withValues(alpha: 0.5),
                                      ),
                                      const Icon(
                                        Icons.play_circle_fill,
                                        color: colors.whiteTemp,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                context
                                    .read<UpdateOrdProvider>()
                                    .imageVideoFiles
                                    .removeAt(i);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.red,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: colors.whiteTemp,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _returnReasonImgFromGallery(
      StateSetter setModalState, BuildContext context) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setModalState(() {
        context.read<UpdateOrdProvider>().imageVideoFiles =
            result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Widget writeOtherReason(
      BuildContext context, void Function(void Function()) setState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: TextFormField(
        style: Theme.of(context).textTheme.titleSmall,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.0,
            ),
          ),
          hintText: getTranslated(context, "ENTER_YOUR_REASON"),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
        onChanged: (value) {
          setState(() {
            context
                .read<UpdateOrdProvider>()
                .otherReasonTextEditingController
                .text = value;
          });
        },
      ),
    );
  }

  Widget submitReturnReasonButton(BuildContext parentContext) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: Platform.isIOS
                ? const EdgeInsets.symmetric(horizontal: 15.0, vertical: 18.0)
                : const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: MaterialButton(
              height: 45.0,
              textColor: Theme.of(context).colorScheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(circularBorderRadius10),
              ),
              onPressed: () async {
                if (_isOtherSelected &&
                    context
                        .read<UpdateOrdProvider>()
                        .otherReasonTextEditingController
                        .text
                        .isEmpty) {
                  setSanckBarNow(getTranslated(context, "PLEASE_ENTER_REASON"));
                  return;
                }

                // Store values before calling API
                final provider = context.read<UpdateOrdProvider>();
                final selectedReason = provider.selectedReason;
                final otherReasonText =
                    provider.otherReasonTextEditingController.text.trim();

                showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text(getTranslated(ctx, 'ARE_YOU_SURE?')),
                      content:
                          Text(getTranslated(ctx, 'WOULD_RETURN_PRODUCT_LBL')),
                      actions: [
                        TextButton(
                          child: Text(getTranslated(ctx, 'YES')),
                          onPressed: () async {
                            Routes.pop(ctx); // Close dialog

                            final returnMedia =
                                List<File>.from(provider.imageVideoFiles);

                            String? responseMessage =
                                await provider.cancelOrder(
                              widget.orderItem.id!,
                              updateOrderItemApi,
                              RETURNED,
                              returnReason: selectedReason.isNotEmpty
                                  ? selectedReason
                                  : '',
                              otherReason: otherReasonText.isNotEmpty
                                  ? otherReasonText
                                  : null,
                              returnItemMedia:
                                  returnMedia, // Pass images and videos
                            );

                            // Check if widget is still mounted before using context
                            if (!context.mounted) return;

                            if (responseMessage != null) {
                              setSanckBarNow(responseMessage); // Show snackbar
                            }

                            Navigator.pop(context, 'update');
                            Routes.pop(context);
                            // Refresh UI
                            // Close bottom sheet
                          },
                        ),
                        TextButton(
                          child: Text(getTranslated(ctx, 'NO')),
                          onPressed: () {
                            Routes.pop(ctx);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              color: colors.primary,
              child: Text(
                getTranslated(context, 'ITEM_RETURN'),
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> Checkpermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        FileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      FileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<void> FileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        filePath = (snapshot.data as List<Directory>).first.path;
      }
    }
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  downloadProductFile(BuildContext context, String orderiteamID) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              context
                  .read<UpdateOrdProvider>()
                  .getDownloadLink(
                    context,
                    orderiteamID,
                  )
                  .then((value) async {
                if (!value) {
                  if (context
                          .read<UpdateOrdProvider>()
                          .currentLinkForDownload !=
                      '') {
                    bool hasPermission = await checkPermission();

                    String target = Platform.isAndroid && hasPermission
                        ? (await ExternalPath.getExternalStoragePublicDirectory(
                            ExternalPath.DIRECTORY_DOWNLOAD,
                          ))
                        : (await getApplicationDocumentsDirectory()).path;

                    String fileName = context
                        .read<UpdateOrdProvider>()
                        .currentLinkForDownload
                        .substring(context
                                .read<UpdateOrdProvider>()
                                .currentLinkForDownload
                                .lastIndexOf('/') +
                            1);
                    String filePath = '$target/$fileName';

                    File file = File(filePath);
                    bool hasExisted = await file.exists();

                    if (hasExisted) {
                      await OpenFilex.open(filePath);
                    }

                    setSnackbar(getTranslated(context, 'Downloading'), context);
                    await FlutterDownloader.enqueue(
                      url: context
                          .read<UpdateOrdProvider>()
                          .currentLinkForDownload,
                      savedDir: target,
                      fileName: fileName,
                      // headers: {'auth': 'test_for_sql_encoding'},
                      showNotification: true,
                      openFileFromNotification: true,
                    ).onError((error, stackTrace) {
                      setSnackbar('Error: $error', context);
                      return null;
                    }).catchError((error, stackTrace) {
                      context
                          .read<UpdateOrdProvider>()
                          .changeStatus(UpdateOrdStatus.isSuccsess);
                      // Handle error appropriately
                    }).whenComplete(() {
                      context
                          .read<UpdateOrdProvider>()
                          .changeStatus(UpdateOrdStatus.isSuccsess);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            getTranslated(context, 'OPEN_DOWNLOAD_FILE_LBL'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.black),
                          ),
                          action: SnackBarAction(
                            label: getTranslated(context, 'VIEW'),
                            textColor: Theme.of(context).colorScheme.fontColor,
                            onPressed: () async {
                              await OpenFilex.open(filePath);
                            },
                          ),
                          backgroundColor: Theme.of(context).colorScheme.white,
                          elevation: 1.0,
                        ),
                      );

                      context
                          .read<UpdateOrdProvider>()
                          .cancelOrder(
                            widget.orderItem.id!,
                            updateOrderItemApi,
                            'delivered',
                          )
                          .then(
                            (value) {},
                          );

                      // You can add code to handle completion here.
                    });
                  } else {
                    context
                        .read<UpdateOrdProvider>()
                        .changeStatus(UpdateOrdStatus.isSuccsess);
                    setSnackbar(
                        'something wrong file is not available yet .', context);
                  }
                }
              });
            },
            icon: const Icon(Icons.download, color: colors.primary),
            label: Text(
              getTranslated(context, 'DOWNLOAD'),
              style: const TextStyle(color: colors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.btnColor),
            ),
          ),
        ),
      ],
    );
  }
}
