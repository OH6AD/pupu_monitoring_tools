# Split input (with trailing newline) to an array of strings
def lines:
    .[0:-1] | split("\n");

# I know the pitfalls of this function with large or small numbers
# which use scientific notation, but this is still more useful than if
# it wound't exist. USE WITH CARE!
def round(digits):
    .+pow(10;-digits-0.30102999566398114) |
    tostring |
    match("[0-9]*\\.[0-9]{"+(digits|tostring)+"}") |
    .string;
