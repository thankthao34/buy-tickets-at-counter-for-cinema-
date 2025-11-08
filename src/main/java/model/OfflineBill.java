package model;

import java.time.LocalDateTime;
import java.util.List;

public class OfflineBill extends Bill {
    private TicketClerk ticketClerk;

    public OfflineBill() {
        super();
    }

    public OfflineBill(TicketClerk ticketClerk) {
        this.ticketClerk = ticketClerk;
    }

    public OfflineBill(TicketClerk ticketClerk, int id, float pointEx, LocalDateTime createDate, Customer customer, float totalPrice, List<Ticket> tickets) {
        super(id, pointEx, createDate, customer, totalPrice, tickets);
        this.ticketClerk = ticketClerk;
    }

    public TicketClerk getTicketClerk() {
        return ticketClerk;
    }

    public void setTicketClerk(TicketClerk ticketClerk) {
        this.ticketClerk = ticketClerk;
    }
    
}
