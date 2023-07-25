
def sum_groups (word_ones):
    (word, ones) = word_ones
    return word + ',' + str(sum(ones))

print(sum_groups())