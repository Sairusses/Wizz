import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:wizz/custom_widgets/custom_text_form_field.dart';

class BudgetNew extends StatefulWidget {
  final int teamBudget;
  final int teamBudgetSpent;
  const BudgetNew({super.key, required this.teamBudget, required this.teamBudgetSpent});
  @override
  BudgetNewState createState() => BudgetNewState();
}
class BudgetNewState extends State<BudgetNew> with AutomaticKeepAliveClientMixin{
  late int teamBudget;
  late int remainingBudget;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late Timestamp dueDate;
  String? dueDateString;
  @override
  void initState() {
    teamBudget = widget.teamBudget;
    remainingBudget = widget.teamBudget - widget.teamBudgetSpent;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.grey[100],
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Record Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                      },
                    icon: Icon(Icons.close, size: 18, color: Colors.black,)
                )
              ],
            ),
            Card(
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Budget:', style:
                        TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),),
                        Text("\$ " '$teamBudget', style:
                        TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Remaining:', style:
                        TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),),
                        Text("\$ " '$remainingBudget', style:
                        TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            CustomTextFormField(
              controller: amountController,
              labelText: 'Amount',
              hint: '0',
              prefixIcon: Icon(Icons.attach_money),
            ),
            SizedBox(height:  20,),
            CustomTextFormField(
                controller: descriptionController,
                labelText: "Description",
                hint: "Add note about this expense.",
                maxLines: 4,
            ),
            SizedBox(height:  20,),
            SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width*.5,
              child: Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.black54),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData(
                            primaryColor: Colors.white,
                            colorScheme: ColorScheme.light(
                              primary: Colors.black,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dueDate = Timestamp.fromDate(pickedDate);
                        dueDateString = DateFormat('MMM d, yyyy').format(dueDate.toDate()).toString();
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: 'No date selected.',
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor: Colors.grey[200],
                          textColor: Colors.black
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                  ),
                  label: Text(
                    dueDateString ?? 'MM / DD / YY',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                // Add your onPressed logic here
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.black87),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                elevation: WidgetStatePropertyAll(6),
                fixedSize: WidgetStatePropertyAll(Size(MediaQuery.of(context).size.width*.5, 40)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )
                ),
              ),
              child: Text("Save Expense"),
            )

          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

