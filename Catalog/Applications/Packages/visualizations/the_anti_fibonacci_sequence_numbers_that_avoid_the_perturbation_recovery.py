def recover_perturbation(dev_func, n):
    return dev_func(n+2) - dev_func(n+1) - dev_func(n)