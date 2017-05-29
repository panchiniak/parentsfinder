Create a folder for your project here.
Place inside it your categories and orphan data files.
At the end you should have the follwoing structure:
* projects/your_project/your_categories_list.csv
Format: 
* <parente>,<child>
* projects/your_project/your_orphans_data.csv
Format:
* one child per line.
ParentsFinder.pm will print out a CSV file using the following pattern:
* projcts/your_project/files/your_project-<current hour>->current-minute>.csv
Format:
* <number of line from entry at your_orphans_data.csv>,<parent>,<child>

