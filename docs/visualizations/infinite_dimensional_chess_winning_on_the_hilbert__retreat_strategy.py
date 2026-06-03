def retreat_square(king, threat):
    return (king[0]+sign(king[0]-threat[0]), king[1]+sign(king[1]-threat[1]))