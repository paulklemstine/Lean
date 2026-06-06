import math
def growth_compare(x):
    eml_d = math.exp(x) - math.log(x)
    gamma = math.gamma(x)
    return gamma > eml_d, gamma / eml_d