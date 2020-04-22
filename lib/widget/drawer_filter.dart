import 'package:flutter/material.dart';
import 'package:note_app/styles.dart';

class DrawerFilterItem extends StatelessWidget {
  DrawerFilterItem({
    Key key,
    this.icon,
    this.iconSize = 26,
    @required this.title,
    this.isChecked,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final String title;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: InkWell(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
          child: Container(
            decoration: ShapeDecoration(
              color:
                  isChecked ? kCheckedLabelBackgroudLight : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            padding: const EdgeInsetsDirectional.only(
              start: 30,
              top: 12.5,
              bottom: 12.5,
              end: 18,
            ),
            child: _content(),
          ),
          onTap: onTap,
        ),
      );

  Widget _content() => Row(
        children: <Widget>[
          if (icon != null)
            Icon(
              icon,
              size: iconSize,
              color: isChecked ? kIconTintCheckedLight : kIconTintLight,
            ),
          if (icon != null) SizedBox(width: 24),
          Text(
            title,
            style: const TextStyle(color: kLabelColorLight, fontSize: 16),
          ),
        ],
      );
}
