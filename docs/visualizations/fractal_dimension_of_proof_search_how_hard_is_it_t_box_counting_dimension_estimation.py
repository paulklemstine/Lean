def box_counting_dimension(successful, total):
    import math
    log_s = [math.log(s) for s in successful if s > 0]
    log_t = [math.log(t) for t in total if t > 0]
    n = len(log_s)
    sum_x, sum_y = sum(log_t), sum(log_s)
    sum_xy = sum(x*y for x,y in zip(log_t, log_s))
    sum_x2 = sum(x*x for x in log_t)
    return (n*sum_xy - sum_x*sum_y) / (n*sum_x2 - sum_x**2)