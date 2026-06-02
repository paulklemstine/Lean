def compose_optimizers(opt1, opt2):
    def composed(proof):
        return opt1.optimize(opt2.optimize(proof))
    return composed