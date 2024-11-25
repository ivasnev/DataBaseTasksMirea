import matplotlib.pyplot as plt
import numpy as np

# Входные данные
t, d, n = 2, 1, 5
points = [(0, 1), (-2, 1), (-2, 3), (0, 3), (2, 5)]

# Функция для отрисовки ромбов
def draw_manhattan_circle(x, y, d):
    # Ромб описывается вершинами по Манхэттенскому расстоянию
    vertices = np.array([
        [x, y + d],
        [x + d, y],
        [x, y - d],
        [x - d, y],
        [x, y + d]  # Для замыкания линии возвращаемся к первой точке
    ])
    plt.plot(vertices[:, 0], vertices[:, 1], 'b-')

# Визуализация окружностей (ромбов)
plt.figure(figsize=(6, 6))
for point in points:
    x, y = point
    draw_manhattan_circle(x, y, d)

# Оси
plt.axhline(0, color='black', linewidth=0.5)
plt.axvline(0, color='black', linewidth=0.5)

# Настройка вида
plt.gca().set_aspect('equal', adjustable='box')
plt.grid(True)
plt.title(f'Manhattan Distance Circles with d = {d}')
plt.show()
