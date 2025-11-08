package model;

import java.util.List;

public class Room {
    private int id;
    private int capacity;
    private String description;
    private String name;
    private List<Seat> seats;

    public Room() {}

    public Room(int id, int capacity, String description, String name, List<Seat> seats) {
        this.id = id;
        this.capacity = capacity;
        this.description = description;
        this.name = name;
        this.seats = seats;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Seat> getSeats() {
        return seats;
    }

    public void setSeats(List<Seat> seats) {
        this.seats = seats;
    }

    
}
