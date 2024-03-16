import mediapipe as mp
import cv2
import numpy as np
import joblib
from flask import Flask, request, send_file
app = Flask(__name__)
def calculate_angle(center_landmark, start_landmark, end_landmark):

    center = np.array(center_landmark)


    start = np.array(start_landmark)


    end = np.array(end_landmark)


    vector1 = start - center


    vector2 = end - center


    angle_radians = np.arccos(
        np.dot(vector1, vector2) / (np.linalg.norm(vector1) * np.linalg.norm(vector2))
    )

    angle_degrees = np.degrees(angle_radians)


    return angle_degrees



def draw_selected_landmarks_on_image(
    rgb_image, landmarks, selected_landmarks, connections
):

    annotated_image = np.copy(rgb_image)


    for index in selected_landmarks:
        landmark = landmarks.landmark[index]


        x, y, z = landmark.x, landmark.y, landmark.z


        x_pixel, y_pixel = int(x * annotated_image.shape[1]), int(
            y * annotated_image.shape[0]
        )


        cv2.circle(
            annotated_image,
            (x_pixel, y_pixel),
            radius=5,
            color=(0, 255, 0),
            thickness=-1,
        )


    for connection in connections:

        start_index, end_index = connection


        start_landmark = landmarks.landmark[start_index]


        end_landmark = landmarks.landmark[end_index]


        start_x, start_y = int(start_landmark.x * annotated_image.shape[1]), int(
            start_landmark.y * annotated_image.shape[0]
        )


        end_x, end_y = int(end_landmark.x * annotated_image.shape[1]), int(
            end_landmark.y * annotated_image.shape[0]
        )


        cv2.line(annotated_image, (start_x, start_y), (end_x, end_y), (0, 255, 0), 2)


    return annotated_image



def render_text(frame, text, x, y):
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.5
    font_thickness = 1
    line_spacing = 20

    (text_width, text_height), _ = cv2.getTextSize(
        text, font, font_scale, font_thickness
    )

    cv2.rectangle(
        frame,
        (x, y - text_height - 5),
        (x + text_width + 5, y + 5),
        (0, 0, 0),
        -1,
    )

    cv2.putText(
        frame,
        text,
        (x, y),
        font,
        font_scale,
        (255, 255, 255),
        font_thickness,
        cv2.LINE_AA,
    )

    return y + text_height + line_spacing



mp_pose = mp.solutions.pose
selected_landmarks_indices = [16,14,12,24,26,28,32]
selected_landmarks_connections = [(16,14),(14,12),(24,26),(26,28),(12,24),(28,32)]

qaadah_ankle = joblib.load('./qaadah/qaadah_ankle_LogisticRegression.pkl')
qaadah_hand = joblib.load('./qaadah/qaadah_hand_LogisticRegression.pkl')
qaadah_knee = joblib.load('./qaadah/qaadah_knee_LogisticRegression.pkl')


qiyam_hip = joblib.load('./qiyam/qiyam_hip_RandomForest.pkl')

ruku_hip = joblib.load('./ruku/random_forest_model_hip(2).joblib')
ruku_knee = joblib.load('./ruku/random_forest_model_knee(2).joblib')

sajda_ankle = joblib.load('./sajda/sajda_ankle_RandomForest.pkl')
sajda_hip = joblib.load('./sajda/sajda_hip_LogisticRegression.pkl')
sajda_knee = joblib.load('./sajda/sajda_knee_LogisticRegression.pkl')


@app.route('/upload', methods=['POST'])
def upload_video():
    file = request.files['video']
    file.save('uploaded_video.mp4')
    return 'Video uploaded successfully'



@app.route('/process', methods=['GET'])
def process_video():

    with mp_pose.Pose(
        static_image_mode=False, min_detection_confidence=0.5, model_complexity=1
    ) as pose:

        video_path = "uploaded_video.mp4"

        video_name = video_path.split("/")[-1]    
        cap = cv2.VideoCapture(video_path)

        if video_name != "":
            output_video_path = f"Output/{video_name}_output.mp4"


    
        fourcc = cv2.VideoWriter_fourcc(*"H264")
        out = cv2.VideoWriter(output_video_path, fourcc, 30.0, (int(cap.get(3)), int(cap.get(4))))



        while cap.isOpened():
            ret, frame = cap.read()

            if not ret:
                break

            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            try:

                results = pose.process(frame_rgb)

                landmark_16 = (
                    results.pose_landmarks.landmark[selected_landmarks_indices[0]].x,
                    results.pose_landmarks.landmark[selected_landmarks_indices[0]].y,
                )

                landmark_14 = (
                    results.pose_landmarks.landmark[selected_landmarks_indices[1]].x,
                    results.pose_landmarks.landmark[selected_landmarks_indices[1]].y,
                )

                landmark_12 = (
                    results.pose_landmarks.landmark[selected_landmarks_indices[2]].x,
                    results.pose_landmarks.landmark[selected_landmarks_indices[2]].y,
                )

                landmark_24 = (
                    results.pose_landmarks.landmark[selected_landmarks_indices[3]].x,
                    results.pose_landmarks.landmark[selected_landmarks_indices[3]].y,
                )

                landmark_26 = (
                    results.pose_landmarks.landmark[selected_landmarks_indices[4]].x,
                    results.pose_landmarks.landmark[selected_landmarks_indices[4]].y,
                )
                landmark_28 = (
                    results.pose_landmarks.landmark[selected_landmarks_indices[5]].x,
                    results.pose_landmarks.landmark[selected_landmarks_indices[5]].y,
                )
                landmark_32 = (
                    results.pose_landmarks.landmark[selected_landmarks_indices[6]].x,
                    results.pose_landmarks.landmark[selected_landmarks_indices[6]].y,
                )
                elbow_angle = calculate_angle(landmark_14, landmark_12, landmark_16)
                elbow_angle = [[elbow_angle]]

                hand_angle = calculate_angle(landmark_12, landmark_24, landmark_14)
                hand_angle = [[hand_angle]]

                hip_angle = calculate_angle(landmark_24, landmark_12, landmark_26)
                hip_angle = [[hip_angle]]

                knee_angle = calculate_angle(landmark_26, landmark_24, landmark_28)
                knee_angle = [[knee_angle]]

                ankle_angle = calculate_angle(landmark_28, landmark_26, landmark_32)
                ankle_angle = [[ankle_angle]]

                frame = draw_selected_landmarks_on_image(
                    frame,
                    results.pose_landmarks,
                    selected_landmarks_indices,
                    selected_landmarks_connections,
                )

            # currentPose = ""
                PostureText = ""

            # if hip_angle[0][0] > 150 and hip_angle[0][0] < 200:
                # currentPose = "QIYAAM"
                # PostureText += currentPose
            # elif hip_angle[0][0] <= 120 and hip_angle[0][0] > 70 and knee_angle[0][0] > 150 and knee_angle[0][0] < 200:
            #     currentPose = "RUKU"
            #     PostureText += currentPose
            # elif hand_angle[0][0] >= 0 and hand_angle[0][0] <= 40 and knee_angle[0][0] > 0 and knee_angle[0][0] < 40 and ankle_angle[0][0] > 130 and ankle_angle[0][0] < 180:
            #     currentPose = "QAADAH"
            #     PostureText += currentPose
            # elif hip_angle[0][0] >40 and hip_angle[0][0] < 110 and knee_angle[0][0] > 47 and knee_angle[0][0] < 112 and ankle_angle[0][0] > 95 and ankle_angle[0][0] < 152:
            #     currentPose = "SAJDA"
            #     PostureText += currentPose
            # else:
            #     currentPose = "Transition"
            #     PostureText += currentPose

            # if currentPose == "QIYAAM":
                if qiyam_hip.predict(hip_angle)[0] == 0:
                    PostureText += "\nhip not straight"
                else :
                    PostureText += "\nGood"

            # elif currentPose == "RUKU":
                if ruku_hip.predict(hip_angle)[0] == 0:
                    PostureText += "\nhip too straight"
                
                if ruku_knee.predict(knee_angle)[0] == 0:
                    PostureText += "\nknee too bent"
                
                if ruku_hip.predict(hip_angle)[0] == 1 and ruku_knee.predict(knee_angle)[0] == 1:
                    PostureText += "\nGood"

            # elif currentPose == "QAADAH":
                if qaadah_ankle.predict(ankle_angle)[0] == 0:
                    PostureText += "\nankle is very straight"

                if qaadah_hand.predict(hand_angle)[0] == 0:
                    PostureText += "\nhands should be on knees"

                if qaadah_knee.predict(knee_angle)[0] == 0:
                    PostureText += "\nSit on your feet"

                if qaadah_ankle.predict(ankle_angle)[0] == 1 and qaadah_hand.predict(hand_angle)[0] == 1 and qaadah_knee.predict(knee_angle)[0] == 1:
                    PostureText += "\nGood"

                
            # elif currentPose == "SAJDA":
                if sajda_ankle.predict(ankle_angle)[0] == 0:
                    PostureText += "\nankle too straight"

                if sajda_hip.predict(hip_angle)[0] == 0:
                    PostureText += "\nknee too straight"

                if sajda_knee.predict(knee_angle)[0] == 0:
                    PostureText += "\nHip too bent"

                if sajda_ankle.predict(ankle_angle)[0] == 1 and sajda_hip.predict(hip_angle)[0] == 1 and sajda_knee.predict(knee_angle)[0] == 1:
                    PostureText += "\nGood"

            # else:
            #     PostureText += "\nTransition"


                multiline_text = f"{PostureText}"
           
                text_x = 10
                text_y = 10

                for line in multiline_text.split("\n"):
                    text_y = render_text(frame, line, text_x, text_y)

            

            
                

                out.write(frame)

                cv2.imshow("Annotated Frame", frame)

                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break
            except:
                pass

        cap.release()
        out.release()

        cv2.destroyAllWindows()

    return send_file(output_video_path, as_attachment=True)
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)