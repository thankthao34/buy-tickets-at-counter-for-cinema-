package model;

public class Ticket {
    private int id;
    private float price;
    private SeatSchedule seatSchedule;

    public Ticket() {}

    public Ticket(int id, float price, SeatSchedule seatSchedule) {
        this.id = id;
        this.price = price;
        this.seatSchedule = seatSchedule;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public float getPrice() {
        return price;
    }

    public void setPrice(float price) {
        this.price = price;
    }

    public SeatSchedule getSeatSchedule() {
        return seatSchedule;
    }

    public void setSeatSchedule(SeatSchedule seatSchedule) {
        this.seatSchedule = seatSchedule;
    }

    
}
