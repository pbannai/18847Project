import os

for filename in ['training_spikes.csv', 'testing_spikes.csv']:
    newfile = filename[0:-4]+'.mem'
    if(os.path.isfile(newfile)):
        os.remove(newfile)
    with open(filename, 'r') as f, open(newfile, 'w') as g:
        count = 0
        newline = ''
        for line in f.readlines():
            num = int(line[0:-2])
            if num == -1:
                #print('1111')
                newline += '1111'
            else:
                #print('{0:04b}'.format(num))
                newline += '{0:04b}'.format(num)
            if count == 7:
                g.write(newline+'\n')
                count = 0
                newline = ''
            else:
                count += 1
