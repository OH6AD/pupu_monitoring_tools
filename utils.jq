# Split input (with trailing newline) to an array of strings
def lines:
    .[0:-1] | split("\n");
