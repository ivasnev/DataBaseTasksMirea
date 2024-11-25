# 2 1 5
# 0 1
# -2 1
# -2 3
# 0 3
# 2 5
def get_points(x, y, d):
    posible_points = set()
    for i in range(-d, d + 1):
        for j in range(-d, d + 1):
            if abs(i) + abs(j) <= d:
                cur_y, cur_x = y + j, x + i
                posible_points.add((cur_x, cur_y))
    return posible_points


def manhattan_distance(point1: tuple, point2: tuple) -> int:
    return abs(point1[0] - point2[0]) + abs(point1[1] - point2[1])


def collision(f_s: set, s_s: set, t):
    res = set()
    for p1 in f_s:
        for p2 in s_s:
            if manhattan_distance(p1, p2) <= t:
                res.add(p2)
    return res


def main():
    t, d, n = map(int, input().split())

    x, y = map(int, input().split())
    old_points = get_points(x, y, d)
    for i in range(1, n):
        x, y = map(int, input().split())
        new_points = get_points(x, y, d)
        old_points = collision(old_points, new_points, t)
    print(len(old_points))
    for p in old_points:
        print(*p)


if __name__ == "__main__":
    main()
