# Do not import anything other than sys and re!
import sys
import re

# this function removes punctuation from a string.
# you should use this before adding a word to the index,
# so that "asdf." and "asdf" and "asdf," are considered to be
# the same word.

def remove_punctuation(s):
  return re.sub(r'[^\w\s]', '', s)

assert(remove_punctuation('asdf.') == 'asdf')
assert(remove_punctuation('asdf,') == 'asdf')
assert(remove_punctuation("?;'.!") == '')

# index is a global dictionary. The keys should be words, and the
# values should be tuples of (filename, line number, position in line).

index = {}
args = sys.argv[1:]


blabla = "asdf asdfl asfasdfasdfasdflol"

def build_index():
    while args:
        fname = args.pop(0)

        f = open(fname)
        line_num = 1

        for ln in f:
            currentLine = ln.lower()
            tempArray = (remove_punctuation(currentLine)).split()

            for x in tempArray:
                if x in index:
                    index[x].append((fname, line_num, currentLine.find(x)))
                else:
                    index[x] = [(fname, line_num, currentLine.find(x))]
            line_num += 1

build_index()

print(index)
print(len(index))

def words(args):
    args = args.pop(0).lower()
    arrayOfWords = [k for k,v in index.items() if k.startswith(args)]
    for x in arrayOfWords:
        print(x)


def occurrences(args):
    args = args.pop(0).lower()
    print(args)
    


def context(args):
  raise Exception("Implement me: context")

def output(args):
  raise Exception("Implement me: output")
    
cmds = {
  'words' : words,
  'occurrences' : occurrences,
  'context' : context,
  'output' : output,
  }

def interact():
  # print the prompt line
  print('> ', end='', flush=True)
  
  for ln in sys.stdin:
    ln = ln.strip().split(' ')
    if ln[0] == 'quit':
      return
    else:
      cmds[ln[0]](ln[1:])

    # print the next prompt line
    print('> ', end='', flush=True)

interact()
