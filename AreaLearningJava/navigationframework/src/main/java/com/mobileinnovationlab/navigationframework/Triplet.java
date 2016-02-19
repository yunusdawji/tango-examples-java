package com.mobileinnovationlab.navigationframework;

/**
 * Created by yunusdawji on 2016-02-17.
 */
public class Triplet {
    public double getFirst() {
        return first;
    }

    public void setFirst(double first) {
        this.first = first;
    }

    public double getSecond() {
        return second;
    }

    public void setSecond(double second) {
        this.second = second;
    }

    public double getThird() {
        return third;
    }

    public void setThird(double third) {
        this.third = third;
    }

    private double first;
    private double second;
    private double third;

    public Triplet(double f, double s, double t) {
        first = f;
        second = s;
        third = t;
    }



}
