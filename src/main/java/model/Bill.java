package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

public class Bill {
    private int id;
    private float pointEx;
    private LocalDateTime createDate;
    private Customer customer;     // có thể trống
    private List<Ticket> tickets; 
    private float totalPrice;

    public Bill() {}

    public Bill(int id, float pointEx, LocalDateTime createDate, Customer customer, float totalPrice, List<Ticket> tickets) {
        this.id = id;
        this.pointEx = pointEx;
        this.createDate = createDate;
        this.customer = customer;
        this.totalPrice = totalPrice;
        this.tickets = tickets;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public float getPointEx() {
        return pointEx;
    }

    public void setPointEx(float pointEx) {
        this.pointEx = pointEx;
    }

    public LocalDateTime getCreateDate() {
        return createDate;
    }

    public void setCreateDate(LocalDateTime createDate) {
        this.createDate = createDate;
    }

    
    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public List<Ticket> getTickets() {
        return tickets;
    }

    public void setTickets(List<Ticket> tickets) {
        this.tickets = tickets;
    }

    public float getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(float totalPrice) {
        this.totalPrice = totalPrice;
    }

    
}
