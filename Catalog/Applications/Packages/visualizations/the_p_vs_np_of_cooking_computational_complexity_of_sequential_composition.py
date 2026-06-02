def sequential_compose(r1, r2):
    return Recipe(cook_time=r1.cook_time + r2.cook_time,
                  verify_time=r1.verify_time + r2.verify_time,
                  destructive=r1.destructive or r2.destructive)