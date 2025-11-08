package model;

public class SeatSchedule {
    private int id;
    private Seat seat;
    private Schedule schedule;
    private int status;

    public SeatSchedule() {}

    public SeatSchedule(int id, Seat seat, Schedule schedule, int status) {
        this.id = id;
        this.seat = seat;
        this.schedule = schedule;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Seat getSeat() {
        return seat;
    }

    public void setSeat(Seat seat) {
        this.seat = seat;
    }

    public Schedule getSchedule() {
        return schedule;
    }

    public void setSchedule(Schedule schedule) {
        this.schedule = schedule;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    
}
