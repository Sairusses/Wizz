import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:wizz/custom_widgets/task_card_member.dart';
import 'package:wizz/services/auth_service.dart';
import 'package:wizz/services/firestore_service.dart';

import '../custom_widgets/custom_text_form_field.dart';

class NewTask extends StatefulWidget{
  final String teamId;
  const NewTask({super.key, required this.teamId});

  @override
  NewTaskState createState() => NewTaskState();

}
class NewTaskState extends State<NewTask>{
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> priorityItems = ['Low', 'Medium', 'High'];
  late List<String> memberItems = [];
  String? selectedPriorityValue;
  List<String> selectedMembers = [];
  late Timestamp dueDate;
  String? dueDateString;

  @override
  initState()  {
    super.initState();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    try {
      QuerySnapshot membersSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamId)
          .collection('members')
          .where('role', isEqualTo: 'member')
          .get();

      List<String> usernames = membersSnapshot.docs
          .map((doc) => doc['username'] as String)
          .toList();
      setState(() {
        memberItems = usernames;
      });
    } catch (e) {
      AuthService().showToast('Error fetching members: $e');
    }
  }

  Future<void> addTaskToTeam({
    required String assignedTo,
    required String title,
    required String description,
    required String priority,
    required double budget,
    required String status,
    required Timestamp dueDate,
  }) async {
    try {
      CollectionReference tasksCollection = FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamId)
          .collection('tasks');

      await tasksCollection.add({
        'assigned_to': assignedTo,
        'title': title,
        'description': description,
        'priority': priority,
        'budget': budget,
        'status': status,
        'due_date': dueDate,
        'created_at': FieldValue.serverTimestamp(),
      });

      AuthService().showToast('Tasks Added');
    } catch (e) {
      AuthService().showToast('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "New Task",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
                controller: titleController,
                labelText: 'Task Title',
                hint: 'Enter task title'
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
                controller: descriptionController,
                labelText: 'Description',
                maxLines: 4,
                hint: 'Add task details'
            ),
            const SizedBox(height: 16),

            //priority
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: const Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 16,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4,),
                        Expanded(
                          child: Text(
                            'Priority',
                            style:  TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    items: priorityItems.map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    value: selectedPriorityValue,
                    onChanged: (value) {
                      setState(() {
                        selectedPriorityValue = value;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      width: 120,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black54,
                        ),
                        color: Colors.white,
                      ),
                      elevation: 2,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.arrow_forward_ios_outlined,
                      ),
                      iconSize: 14,
                      iconEnabledColor: Colors.black,
                      iconDisabledColor: Colors.grey,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16,),


                //Due Date
                Expanded(
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
                      dueDateString ?? "Due Date",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 24),


            //Members list
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                isExpanded: true,
                hint: const Row(
                  children: [
                    Icon(
                      Icons.person_2_outlined,
                      size: 16,
                      color: Colors.black,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Add People',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                items: memberItems.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    // Disable default onTap to prevent closing the menu when an item is tapped
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, menuSetState) {
                        final isSelected = selectedMembers.contains(item);
                        return InkWell(
                          onTap: () {
                            if (isSelected) {
                              selectedMembers.remove(item);
                            } else {
                              selectedMembers.add(item);
                            }
                            // Rebuild the parent widget to reflect changes
                            setState(() {});
                            // Rebuild the dropdown menu to update the checkboxes
                            menuSetState(() {});
                          },
                          child: Container(
                            height: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                if (isSelected)
                                  const Icon(Icons.check_box_outlined)
                                else
                                  const Icon(Icons.check_box_outline_blank),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                // Use a custom display for selected items
                selectedItemBuilder: (context) {
                  return [
                    Text(
                      selectedMembers.isEmpty
                          ? 'No one selected'
                          : selectedMembers.join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ];
                },
                onChanged: (_) {}, // Not used in multiselect dropdown
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black54,
                    ),
                    color: Colors.white,
                  ),
                  elevation: 2,
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                  ),
                  iconSize: 14,
                  iconEnabledColor: Colors.black,
                  iconDisabledColor: Colors.grey,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                  padding: EdgeInsets.only(left: 14, right: 14),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24,),


            // Create Task Button
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  String title = titleController.text.toString();
                  String description = descriptionController.text.toString();
                  if(title.isNotEmpty && description.isNotEmpty && selectedPriorityValue != null && selectedMembers.isNotEmpty){
                    for(String member in selectedMembers){
                      await addTaskToTeam(
                        assignedTo: member,
                        title: title,
                        description: description,
                        priority: selectedPriorityValue!,
                        budget: 500,
                        status: 'In Progress',
                        dueDate: dueDate,
                      );
                    }
                  }
                },
                child: const Text(
                  "Create Task",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}