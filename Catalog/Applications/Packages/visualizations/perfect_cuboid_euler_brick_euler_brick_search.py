def euler_brick_search(bound):
    bricks = []
    for x in range(1, bound+1):
        for y in range(x, bound+1):
            if not is_perfect_square(x*x+y*y): continue
            for z in range(y, bound+1):
                if is_perfect_square(x*x+z*z) and is_perfect_square(y*y+z*z):
                    bricks.append((x,y,z))
    return bricks