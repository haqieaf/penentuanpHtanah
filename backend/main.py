import cv2
import numpy as np
import pandas as pd
import base64
from PIL import Image
from datetime import datetime
from sklearn.cluster import KMeans
from flask import Flask, request, jsonify


app = Flask (__name__)

# @app.route('/health', methods = ['GET'])
# def health():
#     result = {
#         'Status': 'ON'
#         # 'nutrient_recommendation': nutrient_recommendation
#     }

#     return jsonify(result)


@app.route('/process_image', methods = ['POST'])
def process_image():
    # Menerima gambar dari aplikasi Flutter
    file = request.files['image']
    image = cv2.imdecode(np.frombuffer(file.read(),np.uint8),cv2.IMREAD_COLOR)
    latitude = request.form.get('latitude')
    longitude = request.form.get('longitude')
    # if file:
    #     image = Image.open(io.BytesIO(file.read()))

    # Resize gambar tanah
    resized_image = cv2.resize(image, (400, 400))

    # Blur gambar menggunakan median blur
    blurred_image = cv2.medianBlur(resized_image, 5)

    image = cv2.cvtColor(blurred_image, cv2.COLOR_BGR2RGB)

    # Melakukan segmentasi menggunakan K-means
    flattened_image = image.reshape((-1, 3))
    k = 1  # Jumlah cluster
    kmeans = KMeans(n_clusters=k)
    kmeans.fit(flattened_image)
    segmented_image = kmeans.cluster_centers_[kmeans.labels_]
    segmented_image = segmented_image.reshape(blurred_image.shape)

    # Mengubah nilai RGB menjadi integer
    segmented_image = segmented_image.astype(np.uint8)

    #Encode gambar hasil segmentasi ke format base64
    _, img_encoded = cv2.imencode('.png', cv2.cvtColor(segmented_image, cv2.COLOR_RGB2BGR))
    base64_segmented_image = base64.b64encode(img_encoded).decode('utf-8')


    # Mencocokkan warna dengan database 
    color_data = pd.read_csv('D:\Perkuliahan\PA\WarnaTanah.csv')
    color_values = color_data[['Red', 'Green', 'Blue']].values
    color_names = color_data['Name'].values

    min_distance = float('inf')
    matched_color = None

    for i in range(len(color_values)):
        distance = np.sqrt(np.sum((segmented_image - color_values[i]) ** 2))
        if distance < min_distance:
            min_distance = distance
            matched_color = color_names[i]

    
    # Mendapatkan informasi warna RGB
    rgb_info = {
        'Red': int(segmented_image[0, 0, 0]),
        'Green': int(segmented_image[0, 0, 1]),
        'Blue': int(segmented_image[0, 0, 2])
    }
    


    # Mendapatkan hasil pH dan rekomendasi nutrisi dari database
    ph_value = color_data[color_data['Name'] == matched_color]['pH'].values[0]
    # nutrient_recommendation = color_data[color_data['Color'] == matched_color]['Nutrient'].values[0]

    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    # # Mengirimkan hasil ke aplikasi Flutter
    # resultph = {
    #     'pH': ph_value
    #     # 'color': matched_color,
    #     # 'nutrient_recommendation': nutrient_recommendation
    # }
    # return str(resultph['pH']) ,200

    result = {
        'pH': ph_value,
        'color_info': rgb_info,
        'matched_color': matched_color,
        'segmented_image': base64_segmented_image,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,

    }

    return jsonify(result), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)