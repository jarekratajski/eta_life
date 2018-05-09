package pl.setblack.life;


import javafx.application.Application;
import javafx.concurrent.ScheduledService;
import javafx.concurrent.Task;
import javafx.embed.swing.SwingFXUtils;
import javafx.scene.Group;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;
import javafx.util.Duration;

import java.awt.image.BufferedImage;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class GameOfLife extends Application {
    ExecutorService executorService = Executors.newSingleThreadExecutor();

    int lastState = 0;
    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Drawing Operations Test");
        Group root = new Group();
        int wi = 100;
        int hi = 100;
        int cwi= wi*6;
        int chi= hi*6;
        BufferedImage image = new BufferedImage(wi, hi, BufferedImage.TYPE_3BYTE_BGR);


        int state = Life.initEmpty(wi-1, hi-1);

        for (int i=0 ; i < wi/2; i++) {
            state = Life.setCell(state, i+wi/4, hi/2, java.awt.Color.BLUE);
        }

        for (int i=0 ; i < wi/2; i++) {
            state = Life.setCell(state, i+wi/4, hi/4, java.awt.Color.GREEN);
        }

        for (int i=0 ; i < wi/2; i++) {
            state = Life.setCell(state, i+wi/4, hi/4+hi/2, java.awt.Color.RED);
        }

        /*for (int i=0 ; i < hi/2; i++) {
            state = Life.setCell(state, wi/2, i+ hi/4, java.awt.Color.GREEN);
        }*/


        lastState = state;
        Life.fillImage(lastState, image);

        BorderPane border = new BorderPane();

        Image fxImage = SwingFXUtils.toFXImage(image, null);

        Canvas canvas = new Canvas(cwi, chi);
        GraphicsContext gc = canvas.getGraphicsContext2D();
        gc.drawImage(fxImage,0,0, cwi, chi);
        Button button = new Button("next>>");

        Runnable makeStep = () -> {
            GraphicsContext gc1 = canvas.getGraphicsContext2D();
            lastState = Life.newState(lastState);
            System.out.println("new state:"+ lastState);
            Life.fillImage(lastState, image);
            Image fxImage1 = SwingFXUtils.toFXImage(image, null);


            gc1.drawImage(fxImage1,0,0, cwi, chi);

        };

        button.setOnAction( e -> {
            makeStep.run();
        });
        border.setCenter(canvas);
        Button autobutton = new Button("auto");
        autobutton.setOnAction( e -> {
            ScheduledService<Void> svc = new ScheduledService<Void>() {
                protected Task<Void> createTask() {
                    return new Task<Void>() {
                        protected Void call() {

                            makeStep.run();
                            return null;
                        }
                    };
                }
            };
            svc.setPeriod(Duration.millis(20));
            svc.start();

        });
        HBox hbox = new HBox(8);
        hbox.getChildren().addAll(button, autobutton);
        border.setBottom(hbox);
        primaryStage.setScene(new Scene(border));
        primaryStage.show();
    }


}