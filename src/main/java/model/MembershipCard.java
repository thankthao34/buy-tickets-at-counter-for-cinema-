package model;

import java.util.Date;

public class MembershipCard {
    private int id;
    private Date registrationDate;
    private float reward_points;
    private String cardNumber;
    private Customer customer;

    public MembershipCard() {}

    public MembershipCard(int id, Date registrationDate, float reward_points, String cardNumber, Customer customer) {
        this.id = id;
        this.registrationDate = registrationDate;
        this.reward_points = reward_points;
        this.cardNumber = cardNumber;
        this.customer = customer;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Date getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(Date registrationDate) {
        this.registrationDate = registrationDate;
    }

    public float getReward_points() {
        return reward_points;
    }

    public void setReward_points(float reward_points) {
        this.reward_points = reward_points;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    
}
